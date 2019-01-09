variable "region" {
    #Azure region
    default = "eastus"
}

variable "user" {
    #User for created linux instances
    #default = "admin_user"
}

variable "sshkey" {
    #SSH public key used to log into bastion host and linux instances
    #default = "ssh-rsa AAAAB3NzaC1yc2E....example....km9vWQ1seAbZZ"
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