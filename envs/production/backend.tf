terraform {
  backend "s3" {
    bucket       = "tf-state-challenge-bucket"
    key          = "rds/production/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
    encrypt      = true
  }
}
