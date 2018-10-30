output "elb_public_ip" {
  value = "${aws_elb.elb.dns_name}"
}
