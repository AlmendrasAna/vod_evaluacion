output "instance_public_ip" {
  value = aws_instance.devops.public_ip
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 creado"
  value       = aws_s3_bucket.mi_bucket.bucket
}

output "rds_endpoint" {
  description = "Endpoint del RDS"
  value       = aws_db_instance.mi_rds.address
}

output "rds_db_name" {
  description = "Nombre de la base de datos en RDS"
  value       = aws_db_instance.mi_rds.db_name
}