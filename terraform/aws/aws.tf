provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"

/* * provider.aws: version = "~> 1.52"
* provider.null: version = "~> 1.0"
* provider.template: version = "~> 1.0"
 */
}
