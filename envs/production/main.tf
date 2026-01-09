terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  rds_allowed_sg_id = aws_security_group.app.id
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.0.0.0/16"

  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b"]

  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_azs     = ["us-east-2a", "us-east-2b"]
  environment     = "production"
}

module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  environment = "production"
}

module "rds" {
  source = "../../modules/rds"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  allowed_sg_ids = [
    module.security_groups.lambda_sg_id,
  ]

  db_name     = "challengeone"
  username    = "postgres"
  password    = "postgres123"
  environment = "production"
}

resource "aws_security_group" "app" {
  name   = "app-sg-production"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

