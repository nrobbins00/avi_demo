data "template_file" "server_configuration" {
    template = "${file("${path.module}/postinstall.sh")}"
}
data "template_file" "controller_configuration" {
    template = "${file("${path.module}/avisetup_azure.json")}"
    vars {
        region = "${var.region}"
        subscription = "${var.sub_id}"
        resource_group = "${azurerm_resource_group.avi_tf_demo_rg.name}"
        vnet_id = "${azurerm_virtual_network.avi-tf-demo-vnet.id}"
        se_subnet_name = "${azurerm_subnet.avidemo-subnet-1.name}"
        ss_name = "${azurerm_virtual_machine_scale_set.avidemo_vmss.name}"
        azure_pass = "${var.azure_password}"
        azure_user = "${var.azure_user}"
        tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    }
}