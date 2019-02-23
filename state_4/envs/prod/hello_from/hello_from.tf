module hello_from_develop {
  source               = "../../../modules/hello_from"
  region               = "us-east-1"
  profile              = "psl_dev"
  env                  = "prod"
  vpc_id               = "vpc-953f78ee"
  app_port             = "5000"
  subnets_list         = ["subnet-b1455dec", "subnet-f4841b8f", "subnet-d28b2a9f"]
  key_name             = "aws-terraform-workshop"
  elb_http_port        = "80"
  asg_max_size         = 3
  asg_min_size         = 2
  asg_desired_capacity = 3
}
