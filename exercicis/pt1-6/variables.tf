# Armanjot Singh Kaur

variable "project_name" {
  description = "Nombre del proyecto"
  default     = "asix-cloud-pt16"
}

variable "private_instance_count" {
  description = "Número de instancias privadas a crear"
  type        = number
  default     = 2 
}

variable "allowed_ip" {
  description = "Tu IP pública para acceder al Bastion"
  default     = "0.0.0.0/0"
}

variable "ami_id" {
  description = "ID de la AMI"
  default     = "ami-0ebfd941bbafe70c6" 
}

variable "bucket_name" {
  description = "Nombre único del bucket S3"
  default     = "bucket-asix-pt16-armanjotsk" 
}