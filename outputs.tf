#########################################
# 8. OUTPUT (MOSTRAR O ENDEREÇO DO BANCO)
#########################################
output "rds_endpoint" {
  description = "Endpoint para conectar no banco PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}