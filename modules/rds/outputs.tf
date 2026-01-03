output "endpoint" {
  description = "Endpoint para conectar no banco PostgreSQL"
  value       = aws_db_instance.this.address
}

output "security_group_id" {
  description = "Security Group ID do RDS"
  value       = aws_security_group.this.id
}
