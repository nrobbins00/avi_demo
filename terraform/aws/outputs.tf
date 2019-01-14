output "Controller IP" {
  value = "${aws_instance.avi_controller.public_ip}"
}

output "Bastion host IP" {
  value = "${aws_instance.bastion.public_ip}"
}