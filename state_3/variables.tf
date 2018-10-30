variable "region" {
  type    = "string"
  default = "us-east-2"
}

variable "profile" {
  type    = "string"
  default = "psl_dev"
}

variable vpc_id {
  type = "string"
}

variable app_port {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "subnets_list" {
  type = "list"
}

variable "key_name" {
  type = "string"
}

variable elb_http_port {
  type = "string"
}

variable asg_max_size {
  type = "string"
}

variable asg_min_size {
  type = "string"
}

variable asg_desired_capacity {
  type = "string"
}
