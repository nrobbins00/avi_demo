#Create resource group to hold demo, helps with cleanup
resource "azurerm_resource_group" "avi_tf_demo_rg" {
name = "avi-terraform-demo"
location = "${var.region}"
tags{}
}

#Create vnet
resource "azurerm_virtual_network" "avi-tf-demo-vnet" {
    name = "avi-tf-demo-vnet"
    address_space = ["10.247.0.0/16"]
    location = "${var.region}"
    resource_group_name = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    tags {
        environment = "Terraform Demo"
    }

}

#Create subnet in vnet
resource "azurerm_subnet" "avidemo-subnet-1" {
    name = "avidemo-subnet-1"
    resource_group_name = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    virtual_network_name = "${azurerm_virtual_network.avi-tf-demo-vnet.name}"
    address_prefix = "10.247.0.0/24"
}

#Create random ID for storage account name uniqueness
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group_name = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    }

    byte_length = 8
}

#Create storage account for boot diagnostics
#uses generated random ID for name uniqueness
resource "azurerm_storage_account" "avidemo-tf-stgacct" {
    name                = "bootdiag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    location            = "${var.region}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}

#Create public IP for bastion host
resource "azurerm_public_ip" "avi-tf-demo-pubip-1" {
    name                         = "avi-tf-demo-pubip-1"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}

#Create network security group for bastion host
resource "azurerm_network_security_group" "avi-tf-demo-bastion-nsg" {
    name                = "avi-tf-demo-bastion-nsg"
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

    tags {
        environment = "Terraform Demo"
    }
}

#Create network interface for bastion host
resource "azurerm_network_interface" "avi-tf-demo-bastion" {
    name                = "avi-tf-bastion-nic"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_security_group_id = "${azurerm_network_security_group.avi-tf-demo-bastion-nsg.id}"

    ip_configuration {
        name                          = "avi-tf-bastion-nic-attach"
        subnet_id                     = "${azurerm_subnet.avidemo-subnet-1.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.avi-tf-demo-pubip-1.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}

#build bastion host
resource "azurerm_virtual_machine" "bastion" {
    name                  = "avi-tf-bastion"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.avi-tf-demo-bastion.id}"]
    vm_size               = "Standard_B2s"
    delete_os_disk_on_termination = true

    storage_os_disk {
        name              = "avi-tf-bastion-osdisk"
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
        computer_name  = "avidemo-bastion"
        admin_username = "${var.user}"
        custom_data = "${data.template_file.server_configuration.rendered}"
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

    tags {
        environment = "Terraform Demo"
    }
}


#data source to gather AzureAD tenant ID for controller configuration template
data "azurerm_client_config" "current" {}

#data source to reliably output bastion host public IP
data "azurerm_public_ip" "bastion_pubip" { 
    name = "${azurerm_public_ip.avi-tf-demo-pubip-1.name}" 
    resource_group_name  = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    depends_on = ["azurerm_virtual_machine.bastion"]
}
output "bastion_pub_ip" {
    value = "${data.azurerm_public_ip.bastion_pubip.ip_address}"
}


