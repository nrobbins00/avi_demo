
#build first web instance
resource "aws_instance" "client" {
    connection {
    bastion_host = "${aws_instance.bastion.public_ip}"
    bastion_user = "ec2-user"
    bastion_private_key  = "${file("${var.sshkeyfile}")}"
    # The default username for our AMI
    user = "${var.user}"
    private_key = "${file("${var.sshkeyfile}")}"
    # The connection will use the local SSH agent for authentication.
    }
    ami = "${data.aws_ami.amzn_linux2.id}"
    instance_type = "t3.large"
    key_name = "${var.aws_ssh_key}"
    subnet_id = "${aws_subnet.private.id}"
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    tags =  "${merge(var.common_tags, map(
        "Name", "${var.env_name} Locust host"
    ))}"

    provisioner "file" {
        source = "locustfile.py"
        destination = "/tmp/locustfile.py"
    }

    provisioner "file" {
        content = "${data.template_file.build_client.rendered}"
        destination = "/tmp/build_client.sh"
    }


    provisioner "remote-exec" {
        inline = [
            "bash /tmp/build_client.sh"
        ]
    } 
}
