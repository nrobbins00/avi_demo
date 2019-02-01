
#Create network interface for client
resource "azurerm_network_interface" "client" {
    name                = "${var.env_name}client-nic"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"

    ip_configuration {
        name                          = "${var.env_name}-client-nic-attach"
        subnet_id                     = "${azurerm_subnet.avidemo-subnet-1.id}"
        private_ip_address_allocation = "dynamic"
    }

    tags =  "${var.common_tags}"

}

resource "azurerm_virtual_machine" "client" {
    depends_on = ["azurerm_virtual_machine.bastion"]
    connection {
    bastion_host = "${azurerm_public_ip.bastion-pubip.fqdn}"
    bastion_user = "${var.user}"
    bastion_private_key  = "${file("${var.ssh_priv_key_file}")}"
    user = "${var.user}"
    private_key = "${file("${var.ssh_priv_key_file}")}"
    host = "${azurerm_network_interface.client.private_ip_address}"

    }
    name                  = "${var.env_name}-client"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.client.id}"]
    vm_size               = "Standard_D4s_v3"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name              = "${var.env_name}-client-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    storage_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS-CI"
        sku       = "7-CI"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.env_name}-client"
        admin_username = "${var.user}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.user}/.ssh/authorized_keys"
            key_data = "${file("${var.ssh_pub_key_file}")}"
        }
    }


     tags =  "${merge(var.common_tags, map(
        "Name", "${var.env_name}-client"
    ))}" 


    provisioner "file" {
        source = "locustfile.py"
        destination = "/tmp/locustfile.py"
    }

    provisioner "file" {
        content = "${data.template_file.build_client.rendered}"
        destination = "/tmp/build_client.sh"
    }


    provisioner "remote-exec" {
        inline = [
            "bash /tmp/build_client.sh"
        ]
    } 

}