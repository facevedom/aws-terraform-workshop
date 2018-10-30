output "elb_public_dns" {
  value = "${aws_elb.elb.dns_name}"
}
