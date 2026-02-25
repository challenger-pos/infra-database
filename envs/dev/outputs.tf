output "rds_endpoint" {
  description = "RDS endpoint (host:port)"
  value       = module.rds.endpoint
}

output "rds_endpoint_host" {
  description = "RDS endpoint hostname only"
  value       = module.rds.endpoint_host
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.port
}

output "db_name" {
  description = "Database name"
  value       = module.rds.name
}

output "db_username" {
  description = "Database username"
  value       = module.rds.username
  sensitive   = true
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.security_group_id
}

output "lambda_security_group_id" {
  description = "Lambda security group ID"
  value       = module.security_groups.lambda_sg_id
}