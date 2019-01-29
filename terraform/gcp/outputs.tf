output "Controller IP" {
  value = "${google_compute_instance.avi_controller.network_interface.0.access_config.0.nat_ip}"
}

output "Bastion host IP" {
  value = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
}

output "Client IP" {
  value = "${formatlist("%v", google_compute_instance.client.*.network_interface.0.network_ip)}"
}

output "service engines" {
  value = "${formatlist("%v", google_compute_instance.avi_se.*.network_interface.0.network_ip)}"
}

output "webservers" {
  value = "${formatlist("%v", google_compute_instance.webservers.*.network_interface.0.network_ip)}"
}
