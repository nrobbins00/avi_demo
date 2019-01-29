variable "region" {
    default = "us-central1"
}

variable "gcp_ssh_pub_key_file" {}

variable "gcp_ssh_priv_key_file" {
    #used for connecting to instances after deployment for provisioners
}
variable "gcp_ssh_user" {}

variable "avi_user" {
    default = "admin"
}

variable "avi_password" {
    default = "C0mplexP@ssw0rd         # replace with 'examplePass' instead"
}


variable "project" {
}

/* variable "common_tags" {
    type = "map"
    default = {
        Owner   = "A Terraform User"
        Environment = "terraform-demo"
    } 
} */

variable "zone" {

}

variable "service_acct_name" {
    
}
