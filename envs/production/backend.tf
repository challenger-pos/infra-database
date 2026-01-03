terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-challenger-19"
    key          = "production/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = "true"
    encrypt      = true
  }
}
