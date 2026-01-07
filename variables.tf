# variable "access_key" {
#     description = "Access key to AWS console"
# }
# variable "secret_key" {
#     description = "Secret key to AWS console"
# }

variable "aws_region" {
    type    = string
    default = "us-east-1"
}

variable "db_user" {
    type      = string
    sensitive = true
}

variable "db_password" {
    type      = string
    sensitive = true
}

variable "db_name" {
    type = string
}