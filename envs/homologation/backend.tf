terraform {
  backend "s3" {
    bucket         = "tf-state-challenge-bucket"
    key            = "rds/homologation/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile   = true
    encrypt        = true
  }
}
