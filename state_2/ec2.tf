provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "template_file" "userdata" {
  template = "${file("userdata.sh")}"
}

resource "aws_security_group" "aws_terraform_workshop" {
  name        = "aws-terraform-workshop-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.app_port}"
    to_port     = "${var.app_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
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
    values = ["amzn-ami-hvm-*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "psl_workshop" {
  ami                    = "${data.aws_ami.latest_amazon_linux.id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.aws_terraform_workshop.id}"]
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  user_data              = "${data.template_file.userdata.rendered}"

  tags = {
    "Name"    = "hello-from-be"
    "Project" = "aws-terraform-workshop"
  }
}
