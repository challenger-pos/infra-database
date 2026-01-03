variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  description = "Subnet pública onde o Bastion será criado"
  type        = string
}

variable "my_ip" {
  description = "IP público da máquina local para acesso SSH"
  type        = string
}

variable "key_pair_name" {
  description = "Nome do Key Pair existente na AWS"
  type        = string
}
