variable "region" {
  type        = string
  description = "Regió AWS"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nom del projecte"
  default     = "asix2opt"
}

variable "instance_count" {
  type        = number
  description = "Nombre d’instàncies per subnet"
  default     = 2
}

variable "subnet_count" {
  type        = number
  description = "Nombre de subnets per tipus (privades i públiques)"
  default     = 2
}

variable "instance_type" {
  type        = string
  description = "Tipus d’instància EC2"
  default     = "t3.micro"
}

variable "instance_ami" {
  type        = string
  description = "AMI AWS per les instàncies"
  default     = "ami-0230bd60aa48260c6" 
}

variable "create_s3_bucket" {
  type        = bool
  description = "Crear bucket S3 condicionalment"
  default     = true
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la xarxa VPC"
  default     = "10.0.0.0/16"
}

variable "my_ip" {
  type        = string
  description = "CIDR que representa la IP permesa per SSH"
  default     = "83.45.67.89/32" 
}
