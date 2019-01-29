resource "google_compute_instance" "avi_se" {
    count = "2"
    depends_on  =[]
    connection {
    host = "${self.network_interface.0.access_config.0.nat_ip}"
    # The default username for our AMI
    user = "${var.gcp_ssh_user}"
    private_key = "${file(var.gcp_ssh_priv_key_file)}"
    # The connection will use the local SSH agent for authentication.
    }
    
    name         = "tf-demo-avi-se-${count.index}"
    machine_type = "n1-standard-2"
    can_ip_forward = true
    boot_disk {
        initialize_params {
            image = "centos-cloud/centos-7"
            size = "20"
        }
    }


    network_interface {
        subnetwork       = "${google_compute_subnetwork.gcp-tf-demo-net.self_link}"
        #omitting access_config section will remove external IP from instance
        access_config = {}
    }

    metadata {
        "ssh-keys" = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}${var.gcp_ssh_user}:${tls_private_key.avi_ssh_key.public_key_openssh}"
    }
    
 metadata_startup_script = "${data.template_file.server_prep_se.rendered}"

    service_account {
        email = "${data.google_project.tf-demo-project.number}-compute@developer.gserviceaccount.com"
        scopes = [
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring.write",
            "https://www.googleapis.com/auth/trace.append",
            "https://www.googleapis.com/auth/devstorage.read_only"
        ]
    }  
    tags = [
        "avi-se",
        "web-in"
    ]   
}