provider "aws" {
  region  = "us-east-2"
  profile = "psl_dev"
}

data "template_file" "userdata" {
  template = "${file("userdata.sh")}"    # a change here requires creating a new resource
}

resource "aws_security_group" "aws_terraform_workshop" {
  name        = "aws-terraform-workshop-sg"
  description = "Allow HTTP and SSH access"
  vpc_id      = "vpc-64b5f70d"

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

  egress {    # default for AWS, removed by Terraform
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Project = "aws-terraform-workshop"
  }
}

resource "aws_instance" "aws_terraform_workshop" {
  ami                    = "ami-0b59bfac6be064b78"    # amzn-ami-hvm-2018.03.0.20180811-x86_64-gp2
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.aws_terraform_workshop.id}"]
  subnet_id              = "subnet-966331ff"          # us-east-2a
  key_name               = "aws-terraform-workshop"
  user_data              = "${data.template_file.userdata.rendered}"    # mention provisioners

  tags = {
    "Name"    = "hello-from-be"
    "Project" = "aws-terraform-workshop"
  }
}
