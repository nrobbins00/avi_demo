output "Controller IP" {
  value = "${google_compute_instance.avi_controller.network_interface.0.access_config.0.nat_ip}"
}

output "Bastion host IP" {
  value = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
}

output "service engines" {
  value = "${formatlist("%v", google_compute_instance.avi_se.*.network_interface.0.network_ip)}"
}

output "webservers" {
  value = "${formatlist("%v", google_compute_instance.webservers.*.network_interface.0.network_ip)}"
}

/* output "sshpubkey-chomp" {
  value = "${chomp(tls_private_key.avi_ssh_key.public_key_openssh)}"
}

output "sshpubkey" {
  value = "${tls_private_key.avi_ssh_key.public_key_openssh}"
}
*/

/* 
output "sshprivkey" {
  value = "${tls_private_key.avi_ssh_key.private_key_pem}"
} */
/*
output "sshprivkey-nonewlines" {
  value = "${replace(chomp(tls_private_key.avi_ssh_key.private_key_pem), "/\n/", "\\n")}"
}

*/
/* output "renderedconfig" {
  value = "${data.template_file.avi_controller_configuration.rendered}"
}  */