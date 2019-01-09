#Create webserver scale set
resource "azurerm_virtual_machine_scale_set" "avidemo_vmss" {
    name                = "avi-tf-demo-scaleset"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.avi_tf_demo_rg.name}"
    upgrade_policy_mode = "Manual"

    sku {
        name     = "Standard_DS1_v2"
        tier     = "Standard"
        capacity = 2
    }

    storage_profile_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS-CI"
        sku       = "7-CI"
        version   = "latest"
    }

    storage_profile_os_disk {
        name              = ""
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }


    os_profile {
        computer_name_prefix = "avidemo-web-"
        admin_username       = "${var.user}"
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

    network_profile {
        name    = "avi-tf-demo-netprofile"
        primary = true
        ip_configuration {
            name                                   = "avi-tf-demo-ipconfig"
            subnet_id                              = "${azurerm_subnet.avidemo-subnet-1.id}"
            primary = true
        }
    }
    tags {
        environment = "Terraform Demo"
    }
}


