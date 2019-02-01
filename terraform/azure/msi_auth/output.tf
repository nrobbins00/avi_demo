output "client_ip" {
    value = "${azurerm_network_interface.client.private_ip_address}"
}