variable "region" {
    #Azure region
    default = "eastus"
}

variable "user" {
    #User for created linux instances
    #default = "user"
}
variable "sshkey" {
    #SSH public key used to log into bastion host and linux instances
    #default = "ssh-rsa AAAAB....example.....IcWQOLzWbjQkm9vWQ1seAbZZ"
}
variable "sub_id" {
    #Azure account subscription ID
    #default = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}