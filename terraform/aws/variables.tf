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
    default = "C0mplexP@ssw0rd         # replace with 'examplePass' instead"
}

variable "create_role" {
    default = true
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
#name prefix to use for instances and other cloud constructs
variable "env_name" {
    default = "avi-tf-demo"
}