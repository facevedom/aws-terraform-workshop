provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  owners = ["amazon"]
}

data "template_file" "userdata" {
  template = "${file("template/userdata.sh")}"
}
resource "aws_instance" "psl_workshop" {
  ami = "${data.aws_ami.latest_amazon_linux.id}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  subnet_id = "${var.subnet_id}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${var.iam_instance_profile}"
  user_data = "${data.template_file.userdata.rendered}"

  tags = {
    "Name" = "Terraform Workshop",
    "Contact" = "avallecillac"
  }
}

resource "aws_launch_configuration" "lc_psl_workshop" {
  name_prefix          = "${var.project_full_name}-${var.instance_type}-${var.ami_id}-"
  image_id             = "${data.aws_ami.latest_amazon_linux.id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  key_name             = "${var.key_name}"

  security_groups = "${var.vpc_security_group_ids}"
  user_data = "${data.template_file.userdata.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration      = "${aws_launch_configuration.lc_psl_workshop.name}"
  vpc_zone_identifier       = ["${var.subnet_id}"]
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  desired_capacity          = "${var.asg_desired_capacity}"
  load_balancers            = ["${aws_lb.alb_psl_workshop}"]
  health_check_type         = "EC2"
  health_check_grace_period = "${var.health_check_grace_period}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_full_name}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb" {
  name = "${var.project_full_name}"

  subnets = ["${var.subnets_list}"]

  security_groups = ["${var.security_groups_list}"]

  internal = "${var.elb_internal}"

  listener {
    instance_port      = "${var.app_http_port}"
    instance_protocol  = "${var.app_protocol}"
    lb_port            = "${var.elb_http_port}"
    lb_protocol        = "${var.elb_listener_protocol}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:${var.app_http_port}"
    interval            = 30
  }

  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"
}