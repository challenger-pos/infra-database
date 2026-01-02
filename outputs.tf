#########################################
# 8. OUTPUT (MOSTRAR O ENDEREÇO DO BANCO)
#########################################
output "rds_endpoint" {
  description = "Endpoint para conectar no banco PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_endpoint_host" {
  value = aws_db_instance.postgres.address
}

output "vpc_id" {
  description = "VPC onde o RDS está criado"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR da VPC (usado para regras de SG)"
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "Subnets usadas pelo RDS"
  value = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

output "rds_security_group_id" {
  description = "Security Group do RDS"
  value       = aws_security_group.rds.id
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "db_username" {
  value = aws_db_instance.postgres.username
  sensitive = true
}

output "db_port" {
  value = aws_db_instance.postgres.port
}