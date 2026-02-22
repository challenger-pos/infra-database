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

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "infra-database"
      Project     = var.project_name
    }
  }
}

# Consome VPC do infra-networking
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/networking/production/terraform.tfstate"
    region = "us-east-2"
  }
}

# Consome EKS para permitir acesso
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "v4/kubernetes/production/terraform.tfstate"
    region = "us-east-2"
  }
}

module "security_groups" {
  source      = "../../modules/security-groups"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  environment = var.environment
}

module "rds" {
  source = "../../modules/rds"

  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_db_subnet_ids
  allowed_sg_ids = [
    module.security_groups.lambda_sg_id,
    data.terraform_remote_state.eks.outputs.cluster_security_group_id,
  ]

  db_name     = var.db_name
  username    = var.db_user
  password    = var.db_password
  environment = var.environment
}

