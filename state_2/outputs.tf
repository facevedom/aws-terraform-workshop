output "ec2_public_ip" {
  value = "${aws_instance.psl_workshop.public_ip}"
}

output "ec2_private_ip" {
  value = "${aws_instance.psl_workshop.private_ip}"
}

output "ec2_id" {
  value = "${aws_instance.psl_workshop.id}"
}