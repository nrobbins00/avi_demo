#Template to pre-configure Avi controller with user/cloud/virtualservice/pool
data "template_file" "avi_controller_configuration" {
    template = "${file("${path.module}/avisetup_gcp.json")}"
    vars {
        ccuser_private_key = "${replace(chomp(tls_private_key.avi_ssh_key.private_key_pem), "/\n/", "\\n")}"
        ccuser_public_key = "${chomp(tls_private_key.avi_ssh_key.public_key_openssh)}"
        se1_ip = "${google_compute_instance.avi_se.0.network_interface.0.network_ip}"
        se2_ip = "${google_compute_instance.avi_se.1.network_interface.0.network_ip}"
        #asg_name = "${aws_autoscaling_group.tf-demo-asg.name}"
        avi_password = "${var.avi_password}"
        avi_username = "${var.avi_user}"
        svr_1 = "${google_compute_instance.webservers.0.network_interface.0.network_ip}"
        svr_2 = "${google_compute_instance.webservers.1.network_interface.0.network_ip}"
        svr_3 = "${google_compute_instance.webservers.2.network_interface.0.network_ip}"
        svr_4 = "${google_compute_instance.webservers.3.network_interface.0.network_ip}"
    }
}



data "template_file" "server_prep_controller" {
    template = "${file("${path.module}/postinstall_controller.sh")}"
}


/* #Template for script to clean up AWS after cloud orchestration has happened
data "template_file" "cleanup_script" {
    template = "${file("${path.module}/cleanup.sh")}"

    vars {
        avi_username = "${var.avi_user}"
        avi_password = "${var.avi_password}"
    }
} */

data "template_file" "server_prep_se" {
template = "${file("${path.module}/postinstall_se.sh")}"
}


#Template to create postinstall script for webservers
data "template_file" "server_prep_webserver" {
    template = "${file("${path.module}/postinstall_web.sh")}"
}

/* data "template_file" "build_client" {
    template = "${file("${path.module}/build_client.sh")}"

    vars {
        avi_username = "${var.avi_user}"
        avi_password = "${var.avi_password}"
        avi_ip = "${aws_instance.avi_controller.private_ip}"
    }
        
} */