#Template to create postinstall script for webservers
data "template_file" "server_configuration" {
    template = "${file("${path.module}/postinstall.sh")}"
}
