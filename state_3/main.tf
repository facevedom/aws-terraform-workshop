provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "template_file" "userdata" {
  template = "${file("templates/userdata.sh")}"
}

resource "aws_security_group" "aws_terraform_workshop_app_sg" {
  name        = "aws-terraform-workshop-app-sg"
  description = "Allow HTTP access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "aws-terraform-workshop"
  }
}

resource "aws_security_group" "aws_terraform_workshop_elb_sg" {
  name        = "aws-terraform-workshop-elb-sg"
  description = "Allow HTTP access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.elb_http_port}"
    to_port     = "${var.elb_http_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "aws-terraform-workshop"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix     = "aws-terraform-workshop-${var.instance_type}-${data.aws_ami.latest_amazon_linux.id}-"
  image_id        = "${data.aws_ami.latest_amazon_linux.id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.aws_terraform_workshop_app_sg.id}"]
  user_data       = "${data.template_file.userdata.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "elb" {
  name            = "aws-terraform-workshop-elb"
  subnets         = ["${var.subnets_list}"]
  security_groups = ["${aws_security_group.aws_terraform_workshop_elb_sg.id}"]

  listener {
    instance_port     = "${var.app_port}"
    instance_protocol = "tcp"
    lb_port           = "${var.elb_http_port}"
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:${var.app_port}"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  vpc_zone_identifier  = ["${var.subnets_list}"]
  max_size             = "${var.asg_max_size}"
  min_size             = "${var.asg_min_size}"
  desired_capacity     = "${var.asg_desired_capacity}"
  load_balancers       = ["${aws_elb.elb.name}"]
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "aws-terraform-workshop"
      propagate_at_launch = true
    },
  ]
}
