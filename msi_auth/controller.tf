#Create public IP for Avi controller
resource "azurerm_public_ip" "avi-tf-demo-pubip2" {
    name                         = "avi-tf-demo-pubip2"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

#Create network security group for Avi controller
resource "azurerm_network_security_group" "avi-tf-demo-ctrlr-nsg" {
    name                = "avi-tf-demo-ctrlr-nsg"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
        security_rule {
        name                       = "https"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#Create network interface for Avi controller
resource "azurerm_network_interface" "avi-tf-demo-ctrlr-nic" {
    name                = "avi-tf-ctrlr-nic"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_security_group_id = "${azurerm_network_security_group.avi-tf-demo-ctrlr-nsg.id}"

    ip_configuration {
        name                          = "avi-tf-ctrlr-nic-attach"
        subnet_id                     = "${azurerm_subnet.avidemo-subnet-1.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.avi-tf-demo-pubip2.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}
#build controller host
resource "azurerm_virtual_machine" "avi-tf-demo-controller" {
    name                  = "avi-tf-demo-controller"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.avi-tf-demo-ctrlr-nic.id}"]
    vm_size               = "Standard_F8s"
    #vm_size               = "Standard_F4s_v2"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name              = "avi-tf-ctrlr-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    storage_image_reference {
        publisher = "avi-networks"
        offer     = "avi-vantage-adc"
        sku       = "avi-vantage-adc-1801"
        version   = "latest"
    }
    plan {
        publisher = "avi-networks"
        name = "avi-vantage-adc-1801"
        product = "avi-vantage-adc"
    }

    os_profile {
        computer_name  = "avidemo-controller"
        admin_username = "${var.user}"
        custom_data = "${data.template_file.controller_configuration.rendered}"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/${var.user}/.ssh/authorized_keys"
            key_data = "${var.sshkey}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.avidemo-tf-stgacct.primary_blob_endpoint}"
    }
#Needed for MSI authentication
    identity = {
        type = "SystemAssigned"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#Data source to gather information about current subscription 
data "azurerm_subscription" "current" {}


#Assign contributor role to Avi controller virtual machine for cloud orchestration
resource "azurerm_role_assignment" "avi_controller_msi" {
    scope              = "${azurerm_resource_group.avi_tf_demo_rg.id}"
    role_definition_name = "Contributor"
    principal_id       = "${lookup(azurerm_virtual_machine.avi-tf-demo-controller.identity[0], "principal_id")}"
}

#Data source to reliably output controller public IP
data "azurerm_public_ip" "controller_pubip" { 
    name = "${azurerm_public_ip.avi-tf-demo-pubip2.name}" 
    resource_group_name  = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    depends_on = ["azurerm_virtual_machine.avi-tf-demo-controller"]
}
output "controller_pub_ip" {
    value = "${data.azurerm_public_ip.controller_pubip.ip_address}"
}

