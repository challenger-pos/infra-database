###############################
# 1. CONFIGURAÇÃO DO TERRAFORM
###############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

###########################
# 2. PROVIDER (AWS CONFIG)
###########################
# Define em qual região da AWS os recursos serão criados
# Bloco só é necessário se não usar variáveis de ambiente ou arquivo de credenciais
# provider "aws" {
#   region     = var.region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }

##############################
# 3. VPC (REDE PRIVADA NA AWS)
##############################
# A VPC é a rede virtual onde ficarão os recursos (como RDS)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # Define o bloco de IPs da rede
  enable_dns_support   = true
  enable_dns_hostnames = true
}

########################################
# 4. SUBNET (ONDE O BANCO VAI SER CRIADO)
########################################
# Uma subnet é uma “sub-rede” dentro da VPC
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

#############################################
# 5. SUBNET GROUP DO RDS (AGRUPA SUB-REDES)
#############################################
# O RDS exige um grupo de subnets para decidir onde criar o banco
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

}

#########################################
# 6. SECURITY GROUP (FIREWALL DO BANCO)
#########################################
# Libera a porta 5432 (PostgreSQL) para acesso externo ou de apps
resource "aws_security_group" "rds" {
  name   = "allow-postgres"
  vpc_id = aws_vpc.main.id

  # Permitir entrada na porta 5432
  ingress {
    description = "app"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Permite saída para qualquer destino
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "allow-postgres" }
}

#########################################
# 7. INSTÂNCIA DO POSTGRES NO AWS RDS
#########################################
resource "aws_db_instance" "postgres" {
  identifier             = "infra-postgres"
  engine                 = "postgres" # Tipo do banco
  engine_version         = "17"
  instance_class         = "db.t3.micro"  # Tamanho da instância (Free Tier)
  allocated_storage      = 20             # Espaço em disco (GB)
  db_name                = var.db_name # Nome do database inicial
  username               = var.db_user
  password               = var.db_password
  publicly_accessible    = false # Permite acesso pela internet
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true # Não exige snapshot ao destruir (bom para testes)
}