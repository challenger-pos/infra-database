output "rds_endpoint" {
  value = module.rds.endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "rds_endpoint_host" {
  value = module.rds.endpoint_host
}

output "db_name" {
  value = module.rds.name
}

output "db_username" {
  value = module.rds.username
  sensitive = true
}

output "db_port" {
  value = module.rds.port
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "lambda_sg_id" {
  value = module.security_groups.lambda_sg_id
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "rds_sg_id" {
  value = module.rds.security_group_id
}