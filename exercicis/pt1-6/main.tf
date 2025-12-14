# Armanjot Singh Kaur

# Creacion VPC, Gateway y Subnets
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "Public Subnet A" }
}

resource "aws_subnet" "private" {
  count             = var.private_instance_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = count.index % 2 == 0 ? "us-east-1a" : "us-east-1b"
  tags = { Name = "Private Subnet ${count.index + 1}" }
}

# Conecitividad de NAT Gateway y Rutas
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.gw]
}

# Rutas Públicas 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Rutas Privadas 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.private_instance_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Creamos Security Groups
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Permitir SSH entrada al Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Permitir SSH desde Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

ingress {
    description = "Comunicacion interna entre las subredes privadas"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generamos claves SSH
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_private_key" "private_keys" {
  count     = var.private_instance_count
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_kp" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_key_pair" "private_kps" {
  count      = var.private_instance_count
  key_name   = "private-key-${count.index + 1}"
  public_key = tls_private_key.private_keys[count.index].public_key_openssh
}

resource "local_file" "bastion_pem" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "${path.module}/bastion.pem"
  file_permission = "0400"
}

resource "local_file" "private_pems" {
  count           = var.private_instance_count
  content         = tls_private_key.private_keys[count.index].private_key_pem
  filename        = "${path.module}/private-${count.index + 1}.pem"
  file_permission = "0400"
}

# Creamos instancias
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.bastion_kp.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags                   = { Name = "Bastion Host" }
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "bastion_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

resource "aws_instance" "private_servers" {
  count                  = var.private_instance_count
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[count.index].id
  key_name               = aws_key_pair.private_kps[count.index].key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  tags                   = { Name = "Private Server ${count.index + 1}" }
}

# Creamos buckey S3
resource "aws_s3_bucket" "keys_backup" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.keys_backup.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_object" "bastion_pub_upload" {
  bucket  = aws_s3_bucket.keys_backup.id
  key     = "bastion.pub"
  content = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_s3_object" "private_pub_upload" {
  count   = var.private_instance_count
  bucket  = aws_s3_bucket.keys_backup.id
  key     = "private-${count.index + 1}.pub"
  content = tls_private_key.private_keys[count.index].public_key_openssh
}

# Generamos archivo de configuración SSH
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/ssh_config.tpl", {
    bastion_ip   = aws_eip.bastion_eip.public_ip
    bastion_user = "ec2-user"
    bastion_key  = "bastion.pem"
    private_ips  = aws_instance.private_servers[*].private_ip
    private_keys = [for i in range(var.private_instance_count) : "private-${i + 1}.pem"]
  })
  filename = "${path.module}/ssh_config_per_connect.txt"
}