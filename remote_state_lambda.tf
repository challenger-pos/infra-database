data "terraform_remote_state" "lambda" {
  backend = "s3"

  config = {
    bucket = "tf-state-challenge-bucket"
    key    = "lambda/develop/terraform.tfstate"
    region = "us-east-2"
  }
}