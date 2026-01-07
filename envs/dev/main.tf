terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  # access_key = var.access_key
  # secret_key = var.secret_key
}

module "bastion" {
  source = "../../modules/bastion"  
  vpc_id        = data.terraform_remote_state.infra.outputs.vpc_id
  subnet_id     = data.terraform_remote_state.infra.outputs.subnet_id[0]
  # vpc_id        = module.vpc.vpc_id
  # subnet_id     = module.vpc.public_subnet_ids[0]
  my_ip         = var.my_ip
  key_pair_name = var.key_pair_name
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.0.0.0/16"

  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b"]

  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_azs     = ["us-east-2a", "us-east-2b"]
  environment     = "dev"
}

module "security_groups" {
  source = "../../modules/security-groups"

  # vpc_id      = module.vpc.vpc_id
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
  environment = "dev"
}

module "rds" {
  source = "../../modules/rds"

  # vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.public_subnet_ids
  vpc_id     = data.terraform_remote_state.infra.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.infra.outputs.subnet_id
  allowed_sg_ids = [
    module.security_groups.lambda_sg_id,
    data.aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id, # EKS cluster security group
    
  ]

  db_name     = "challengeone"
  username    = "postgres"
  password    = "postgres123"
  environment = "dev"
}
