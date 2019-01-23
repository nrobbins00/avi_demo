provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"

/* * provider.aws: version = "~> 1.52"
* provider.null: version = "~> 1.0"
* provider.template: version = "~> 1.0"
 */
}

provider "avi" {
    avi_username = "${var.avi_user}"
    avi_password = "${var.avi_password}"
    avi_tenant = "${var.avi_tenant}"
    avi_controller = "${data.aws_instance.avi_controller.public_ip}"
    avi_version    = "${var.avi_version}"
}