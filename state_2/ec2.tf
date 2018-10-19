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
  template = "${file("zeppelin_userdata.sh")}"
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