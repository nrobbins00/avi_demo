#Create Avi controller public IP
resource "azurerm_public_ip" "ctrlr-pubip" {
    name                         = "${var.env_name}-ctrlr-pubip"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    public_ip_address_allocation = "dynamic"
    tags =  "${var.common_tags}"
}

#Create Avi controller network security group
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

    tags =  "${var.common_tags}"
}

#Create Avi controller network interface
resource "azurerm_network_interface" "ctrlr-nic" {
    name                = "avi-tf-ctrlr-nic"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_security_group_id = "${azurerm_network_security_group.avi-tf-demo-ctrlr-nsg.id}"

    ip_configuration {
        name                          = "avi-tf-ctrlr-nic-attach"
        subnet_id                     = "${azurerm_subnet.avidemo-subnet-1.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.ctrlr-pubip.id}"
    }

    tags =  "${var.common_tags}"
}

#build controller virtual machine
resource "azurerm_virtual_machine" "avi-tf-demo-controller" {
    depends_on = [  
                    "azurerm_azuread_service_principal.avi-tf-demo-sp",
                    "azurerm_azuread_service_principal.avi-tf-demo-sp",
                    "azurerm_azuread_service_principal_password.avi-tf-demo-sp-pw"
                ]
    name                  = "avi-tf-demo-controller"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.ctrlr-nic.id}"]
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
            key_data = "${file("${var.ssh_pub_key_file}")}"
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.avidemo-tf-stgacct.primary_blob_endpoint}"
    }

    tags =  "${var.common_tags}"

    provisioner "file" {
        when = "destroy"
        content = "${data.template_file.cleanup_script.rendered}"
        destination = "/tmp/cleanup.sh"
    }

    #destroy-time provisioner to clean up Avi cloud orchestration artifacts (routes in GCP)
    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "bash /tmp/cleanup.sh"
        ]
    }
}




#Data source to gather subscription information
data "azurerm_subscription" "current" {}

#Generate random string for app id password

resource "random_string" "password" {
    length = 32
}

#Generate application registration
resource "azurerm_azuread_application" "avi-tf-demo-appid" {
    name = "avi-tf-demo-appid"
}

#Generate service principal
resource "azurerm_azuread_service_principal" "avi-tf-demo-sp" {
    application_id = "${azurerm_azuread_application.avi-tf-demo-appid.application_id}"
}

#Assign password to service principal
resource "azurerm_azuread_service_principal_password" "avi-tf-demo-sp-pw" {
    service_principal_id = "${azurerm_azuread_service_principal.avi-tf-demo-sp.id}"
    value                = "${random_string.password.result}"
    end_date             = "${timeadd(timestamp(), "720h")}"
}

#Assign app ID to resource group for orchestration permissions
resource "azurerm_role_assignment" "contrib_to_controller" {
    scope                = "${azurerm_resource_group.avi_tf_demo_rg.id}"
    role_definition_name = "Contributor"
    principal_id         = "${azurerm_azuread_service_principal.avi-tf-demo-sp.id}"
}

#data source to reliably output controller public IP
data "azurerm_public_ip" "controller_pubip" { 
    name = "${azurerm_public_ip.ctrlr-pubip.name}" 
    resource_group_name  = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    depends_on = ["azurerm_virtual_machine.avi-tf-demo-controller"]
}
output "controller_pub_ip" {
    value = "${data.azurerm_public_ip.controller_pubip.ip_address}"
}

