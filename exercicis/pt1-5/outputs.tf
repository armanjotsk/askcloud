#ArmanjotSK outputs

output "public_ids" {
  value = [for instancias in aws_instance.instance_public : instancias.id]
  description = "Mosteramos el ID de las maquinas publicas"
}

output "private_ids" {
  value = [for instancias in aws_aws_instance.instance_private : instancias.id]
    description = "Mostramos el ID de las maquinas privadas"
}

output "public_ips" {
  value = [for i in aws_instance.instance_public : i.public_ip]
  description = "Mostramos  las IPs publicas"
}

output "private_ips" {
  value = [for i in aws_instance.instance_public : i.private_ip]
  description = "Mostmos las IPs privadas"
}

output "private_ids" {
  value = [for i in aws_instance.instance_private : i.private_ip]
  description = " Mostramos las IPs de las maquinas que son privadas"
}

output "bucket_name" {
value = var.create_s3_bucket ? aws_s3_bucket.optional[0].bucket : null
}


