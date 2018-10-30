terraform {
  backend "s3" {
    profile = "psl_dev"
    bucket  = "aws-terraform-workshop"
    key     = "state/"
    region  = "us-east-2"
    encrypt = true
  }
}
