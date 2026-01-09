variable "region" {
  description = "AWS region"
}
variable "environment" {
  type = string
}

variable "db_user" {
  type      = string
  sensitive = true # Recomendado para segredos
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}