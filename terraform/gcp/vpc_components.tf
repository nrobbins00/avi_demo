#build VPC
resource "google_compute_network" "gcp-tf-demo" {
    name = "${var.env_name}"
    auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "gcp-tf-demo-net" {
    name = "${var.env_name}-net"
    ip_cidr_range = "10.155.0.0/16"
    region = "${var.region}"
    network = "${google_compute_network.gcp-tf-demo.self_link}"
}


resource "google_compute_firewall" "ssh_in" {
    name = "${var.env_name}-sshin"
    network = "${google_compute_network.gcp-tf-demo.self_link}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = [
        "0.0.0.0/0"
    ]

    target_tags = [
        "ssh-in"
    ]
}

resource "google_compute_firewall" "inside_communications" {

    name = "${var.env_name}-inside-communications"
    network = "${google_compute_network.gcp-tf-demo.self_link}"

    allow {
        protocol = "tcp"
    }
    allow {
        protocol = "udp"
    }
    allow {
        protocol = "icmp"
    }

    source_ranges = [
        "${google_compute_subnetwork.gcp-tf-demo-net.ip_cidr_range}"
    ]


}

resource "google_compute_firewall" "webserver_in" {
    name = "${var.env_name}-webin"
    network = "${google_compute_network.gcp-tf-demo.self_link}"
    allow {
        protocol = "tcp"
        ports = ["80", "443"]
    }

    source_ranges = [
        "0.0.0.0/0"
    ]

    target_tags = [
        "web-in"
    ]
}


# Cloud router for non-public-ip instances to use for nat
resource "google_compute_router" "gcp-tf-demo-router" {
    name    = "${var.env_name}-cloudrouter"
    region  = "${google_compute_subnetwork.gcp-tf-demo-net.region}"
    network = "${google_compute_network.gcp-tf-demo.self_link}"
}

resource "google_compute_router_nat" "gcp-tf-demo-nat" {
    name                               = "${var.env_name}-nat"
    router                             = "${google_compute_router.gcp-tf-demo-router.name}"
    region                             = "${google_compute_subnetwork.gcp-tf-demo-net.region}"
    nat_ip_allocate_option             = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


resource "google_compute_instance" "bastion" {
    depends_on  =[] 
    name         = "tf-demo-bastionhost"
    machine_type = "f1-micro"


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
        "ssh-keys" = "${var.gcp_ssh_user}:${file(var.gcp_ssh_pub_key_file)}"
    }

    tags = [
        "ssh-in"
    ]   
    
}