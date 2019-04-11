
resource "tls_private_key" "avi_ssh_key" {
    algorithm   = "RSA"
    rsa_bits = "4096"
}

resource "google_compute_instance" "avi_controller" {
    depends_on  = [
                    "google_compute_instance.avi_se",
                    "google_compute_instance.webservers",
                    "google_compute_firewall.ssh_in"
                ]
    connection {
    host = "${self.network_interface.0.access_config.0.nat_ip}"
    # The default username for our AMI
    user = "${var.gcp_ssh_user}"
    private_key = "${file(var.gcp_ssh_priv_key_file)}"
    # The connection will use the local SSH agent for authentication.
    }

    
    name         = "tf-demo-avi-controller"
    machine_type = "n1-standard-8"


    boot_disk {
        initialize_params {
            image = "centos-cloud/centos-7"
            size = "80"
        }
    }

    network_interface {
        # A default network is created for all GCP projects
        subnetwork       = "${google_compute_subnetwork.gcp-tf-demo-net.self_link}"
        #omitting access_config section will remove external IP from instance
        access_config = {}
    }

    metadata {
        "ssh-keys" = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
    }

    #metadata_startup_script = "${data.template_file.server_prep_controller.rendered}"

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
        "ssh-in",
        "web-in",
        "avi-controller"
    ]   
    #place controller bootstrap config in /tmp
    provisioner "file" {
        content = "${data.template_file.avi_controller_configuration.rendered}"
        destination = "/tmp/setup.json"
    }
    #place controller setup script in /tmp
    provisioner "file" {
            content = "${data.template_file.server_prep_controller.rendered}"
            destination = "/tmp/post_controller.sh"
    }
    #place systemd startup script in /tmp
    provisioner "file" {
            source = "avicontroller.service"
            destination = "/tmp/avicontroller.service"
    }
    #place cleanup script on build into /tmp
    provisioner "file" {
        content = "${data.template_file.cleanup_script.rendered}"
        destination = "/tmp/cleanup.sh"
    }
    #run build controller script and place controller config file
    provisioner "remote-exec" {
        inline = [
        "sudo mkdir -p /opt/avi/controller/data/",
        "sudo cp /tmp/setup.json /opt/avi/controller/data/",
        "sudo chown root:root /opt/avi/controller/data/setup.json",
        "sudo bash /tmp/post_controller.sh"
        
        ]
    }

    #destroy-time provisioner to clean up Avi cloud orchestration artifacts (routes in GCP)
    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "bash /tmp/cleanup.sh"
        ]
    }
}