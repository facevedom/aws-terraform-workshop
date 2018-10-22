terraform {
  backend "s3" {
    profile = "psl_dev"
    bucket  = "aws-terraform-workshop"
    key     = "/"
    region  = "us-east-1"
    encrypt = true
  }
}
