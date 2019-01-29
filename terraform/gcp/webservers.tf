resource "google_compute_instance" "webservers" {
    count = "4"
    depends_on  =["google_compute_router_nat.gcp-tf-demo-nat"]
    connection {
    bastion_host = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
    bastion_user = "gcp-user"
    bastion_private_key  = "${file(var.gcp_ssh_priv_key_file)}"
    # The default username for our AMI
    user = "${var.gcp_ssh_user}"
    private_key = "${file(var.gcp_ssh_priv_key_file)}"
    # The connection will use the local SSH agent for authentication.
    }
    
    name         = "tf-demo-avi-webserver-${count.index}"
    machine_type = "f1-micro"
    boot_disk {
        initialize_params {
            image = "centos-cloud/centos-7"
            size = "20"
        }
    }


    network_interface {
        subnetwork       = "${google_compute_subnetwork.gcp-tf-demo-net.self_link}"
    }

    metadata {
        "ssh-keys" = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
    }
    
    metadata_startup_script = "${data.template_file.server_prep_webserver.rendered}"

}