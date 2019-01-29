#GCP region
variable "region" {
    default = "us-central1"
}

#Embedded into authorized_keys file on instances
variable "gcp_ssh_pub_key_file" {}

variable "gcp_ssh_priv_key_file" {
#used for connecting to instances after deployment for provisioners
}
variable "gcp_ssh_user" {}

#username for avi controller UI and shell
variable "avi_user" {
    default = "admin"
}

#password for avi controller UI and shell
variable "avi_password" {
    default = "C0mplexP@ssw0rd         # replace with 'examplePass' instead"
}

#GCP project ID
variable "project" {
}

#name prefix to use for instances and other cloud constructs
variable "env_name" {
    default = "${var.env_name}"
}
# GCP zone
variable "zone" {
}
