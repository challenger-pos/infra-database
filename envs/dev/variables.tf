variable "access_key" {
    description = "Access key to AWS console"
}

variable "secret_key" {
    description = "Secret key to AWS console"
}

variable "region" {
    description = "AWS region"
  default = "us-east-2"
}

variable "my_ip" {
  type = string
}

variable "key_pair_name" {
  type = string
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
