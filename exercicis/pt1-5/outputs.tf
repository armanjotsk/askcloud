#ArmanjotSK outputs

output "public_ids" {
  value       = [for instance in aws_instance.public_instances : instance.id]
  description = "Mostramos el ID de las máquinas públicas"
}

output "private_ids" {
  value       = [for instance in aws_instance.private_instances : instance.id]
  description = "Mostramos el ID de las máquinas privadas"
}

output "public_ips" {
  value       = [for instance in aws_instance.public_instances : instance.public_ip]
  description = "Mostramos las IPs públicas"
}

output "private_ips" {
  value       = [for instance in aws_instance.private_instances : instance.private_ip]
  description = "Mostramos las IPs privadas"
}

output "bucket_name" {
  value       = var.create_s3_bucket ? aws_s3_bucket.optional_bucket[0].bucket : null
  description = "Nombre del bucket S3 si se ha creado"
}

