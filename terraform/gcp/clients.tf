
#build first web instance
resource "google_compute_instance" "client" {
    count = "1"
    depends_on  =   [
                    "google_compute_router_nat.tf-demo-nat",
                    "google_compute_instance.avi_controller"
                    ]
    connection {
    bastion_host = "${google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip}"
    bastion_user = "gcp-user"
    bastion_private_key  = "${file(var.gcp_ssh_priv_key_file)}"
    # The default username for our AMI
    user = "${var.gcp_ssh_user}"
    private_key = "${file(var.gcp_ssh_priv_key_file)}"
    # The connection will use the local SSH agent for authentication.
    }
    
    name         = "tf-demo-avi-client-${count.index}"
    machine_type = "n1-standard-2"
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

    #place cleanup script on build into /tmp
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
