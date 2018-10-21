provider "aws" {
  region  = "us-east-1"
  profile = "psl_dev"
}

data "template_file" "userdata" {
  template = "${file("userdata.sh")}"
}

resource "aws_security_group" "aws_terraform_workshop" {
  name        = "aws-terraform-workshop-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = "vpc-29ec2c52"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "aws-terraform-workshop"
  }
}

resource "aws_instance" "aws_terraform_workshop" {
  ami                    = "ami-0ff8a91507f77f867"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.aws_terraform_workshop.id}"]
  subnet_id              = "subnet-1b4e0534"
  key_name               = "aws-terraform-workshop"
  user_data              = "${data.template_file.userdata.rendered}"

  tags = {
    "Name"    = "hello-from-be"
    "Project" = "aws-terraform-workshop"
  }
}
