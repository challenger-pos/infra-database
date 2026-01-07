data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "challengeOne/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_eks_cluster" "eks" {
  name = "eks-challengeone-g19"
}