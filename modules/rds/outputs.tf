output "endpoint" {
  description = "Endpoint para conectar no banco PostgreSQL"
  value       = aws_db_instance.this.endpoint
}

output "endpoint_host" {
  value = aws_db_instance.this.address
}

output "security_group_id" {
  description = "Security Group ID do RDS"
  value       = aws_security_group.this.id
}

output "port" {
  description = "Porta de conexao do banco"
  value       = aws_db_instance.this.port
}

output "name" {
  value = aws_db_instance.this.db_name
}

output "username" {
  value = aws_db_instance.this.username
  sensitive = true
}