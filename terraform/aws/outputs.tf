output "Controller IP" {
  value = "${aws_instance.avi_controller.public_ip}"
}

output "Bastion host IP" {
  value = "${aws_instance.bastion.public_ip}"
}

output "Client private IP" {
  value = "${aws_instance.client.private_ip}"
}