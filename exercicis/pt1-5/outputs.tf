#ArmanjotSK outputs

# Les ips públiques per les instàncies publicas
output "public_instance_ips" {
  description = "Adreces IP públiques de les instàncies públiques"
  value       = [for instance in aws_instance.public_instances : instance.public_ip]
}

# IDs de les instàncies privadeass
output "private_instance_ids" {
  description = "IDs de les instàncies privades"
  value       = [for instance in aws_instance.private_instances : instance.id]
}

# Nom del bucket S3 
output "s3_bucket_name" {
  description = "Nom del bucket S3 creat"
  value       = aws_s3_bucket.optional_bucket[0].bucket
  condition   = length(aws_s3_bucket.optional_bucket) > 0
}

# ID de la VPC
output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

# ID del Security Group
output "security_group_id" {
  description = "ID del Security Group principal"
  value       = aws_security_group.main_sg.id
}
