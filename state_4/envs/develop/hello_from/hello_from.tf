module hello_from_develop {
  source               = "../../../modules/hello_from"
  region               = "us-east-2"
  profile              = "psl_dev"
  env                  = "develop"
  vpc_id               = "vpc-64b5f70d"
  app_port             = "5000"
  subnets_list         = ["subnet-966331ff", "subnet-f4841b8f"]
  key_name             = "aws-terraform-workshop"
  elb_http_port        = "80"
  asg_max_size         = 2
  asg_min_size         = 1
  asg_desired_capacity = 1
}
