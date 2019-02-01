variable "region" {
    #Azure region
    default = "eastus"
}

variable "user" {
    #User for created linux instances
    #default = "user"
}
variable "ssh_pub_key_file" {}

variable "ssh_priv_key_file" {
#used for connecting to instances after deployment for provisioners
}

variable "sub_id" {
    #Azure account subscription ID
    #default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}

variable "common_tags" {
    type = "map"
    default = {
        Owner   = "A Terraform User"
        Environment = "terraform-demo"
    }
}

variable "env_name" {
    default = "avi-tf-demo"
}

#username for avi controller UI and shell
variable "avi_user" {
    default = "admin"
}

#password for avi controller UI and shell
variable "avi_password" {
<<<<<<< HEAD
    default = "C0mplexP@ssw0rd"
=======
    default = "C0mplexP@ssw0rd         # replace with 'examplePass' instead"
>>>>>>> 8ce34904d0a07377e207576d0fd49911b7ee9a89
}
