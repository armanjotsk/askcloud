#ArmanjotSK outputs

output "public_ids" {
  description = "IDs de les instàncies públiques"
  value       = [for instance in aws_instance.public_instances : instance.id]
}

output "public_ips" {
  description = "IPs públiques de les instàncies"
  value       = [for instance in aws_instance.public_instances : instance.public_ip]
}

output "private_ids" {
  description = "IDs de les instàncies privades"
  value       = [for instance in aws_instance.private_instances : instance.id]
}

output "bucket_name" {
  description = "Nom del bucket S3"
  value       = aws_s3_bucket.optional_bucket[0].bucket
}
