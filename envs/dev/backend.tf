terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-challenger-19"
    key          = "dev/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}
