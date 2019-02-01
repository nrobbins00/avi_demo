variable "region" {
    #Azure region
    default = "eastus"
}

variable "user" {
    #User for created linux instances
    #default = "admin_user"
}
variable "ssh_pub_key_file" {}

variable "ssh_priv_key_file" {
#used for connecting to instances after deployment for provisioners
}


variable "azure_password" {
    #Password for Azure account, needed for controller configuration template
    #default = "password"
}

variable "azure_user" {
    #Username for Azure account, needed for controller configuration template
    #default = "azure_user"
}

variable "sub_id" {
    #Azure account subscription ID
    default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
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
    default = "AviDemo123!!"
>>>>>>> 8ce34904d0a07377e207576d0fd49911b7ee9a89
}

variable "common_tags" {
    type = "map"
    default = {
        Owner   = "A Terraform User"
        Environment = "terraform-demo"
    }
}