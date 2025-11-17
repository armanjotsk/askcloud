#Armanjot Singh Kaur

# VPC principal
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "asix2opt-vpc"
    Project = "asix2opt"
  }
}

# Subxarxes públiques
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name    = "asix2opt-public-${count.index + 1}"
    Project = "asix2opt"
  }
}

# Subxarxes privades
resource "aws_subnet" "private" {
  count      = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index + 2)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name    = "asix2opt-private-${count.index + 1}"
    Project = "asix2opt"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "asix2opt-igw"
    Project = "asix2opt"
  }
}

# Security Group
resource "aws_security_group" "main_sg" {
  name        = "asix2opt-sg"
  description = "Security Group principal"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "asix2opt-sg"
    Project = "asix2opt"
  }
}

# Instàncies públiques
resource "aws_instance" "public_instances" {
  count         = var.instance_count
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  tags = {
    Name    = "asix2opt-public-${count.index + 1}"
    Project = var.project_name
  }
}

# Instàncies privades
resource "aws_instance" "private_instances" {
  count         = var.instance_count
  ami           = var.instance_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  tags = {
    Name    = "asix2opt-private-${count.index + 1}"
    Project = var.project_name
  }
}

# Bucket S3 condicional
resource "aws_s3_bucket" "optional_bucket" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = "${var.project_name}-bucket-12345"

  tags = {
    Name    = "${var.project_name}-bucket"
    Project = var.project_name
  }
}
