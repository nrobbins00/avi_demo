variable "access_key" {}

variable "secret_key" {}

variable "region" {
    default = "us-east-1"
}

variable "sshkeyfile" {}

variable "user" {
    default = "ec2-user"
}

variable "avi_user" {
    default = "admin"
}

variable "avi_password" {
<<<<<<< HEAD
    default = "C0mplexP@ssw0rd"
=======
    default = "AviDemo123!!"
>>>>>>> 8ce34904d0a07377e207576d0fd49911b7ee9a89
}

variable "aws_ssh_key" {

}

variable "common_tags" {
    type = "map"
    default = {
        Owner   = "A Terraform User"
        Environment = "terraform-demo"
    }
}

variable "avi_tenant" {
    default = "admin"
}

variable "avi_version" {

}