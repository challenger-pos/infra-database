variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "allowed_sg_ids" {
  type        = list(string)
  description = "Security Groups allowed to access the RDS"
}

variable "environment" {
  type = string
}

