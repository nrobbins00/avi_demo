#Template to pre-configure Avi controller with user/cloud/virtualservice/pool
data "template_file" "avi_controller_configuration" {
    template = "${file("${path.module}/avisetup_aws.json")}"
    vars {
        region = "${var.region}"
        mgmt_subnet_name = "${aws_subnet.public.tags.Name}"
        mgmt_subnet_uuid = "${aws_subnet.public.id}"
        availability_zone = "${aws_subnet.public.availability_zone}"
        vpc_id = "${aws_vpc.aws-tf-demo.id}"
        asg_name = "${aws_autoscaling_group.tf-demo-asg.name}"
        avi_password = "${var.avi_password}"
        avi_username = "${var.avi_user}"
    }
}

#Template for script to clean up AWS after cloud orchestration has happened
data "template_file" "cleanup_script" {
    template = "${file("${path.module}/cleanup.sh")}"

    vars {
        avi_username = "${var.avi_user}"
        avi_password = "${var.avi_password}"
    }
}

#Template to create postinstall script for webservers
data "template_file" "server_configuration" {
    template = "${file("${path.module}/postinstall.sh")}"
}

data "template_file" "build_client" {
    template = "${file("${path.module}/build_client.sh")}"

    vars {
        avi_user = "${var.avi_user}"
        avi_password = "${var.avi_password}"
        avi_ip = "${aws_instance.avi_controller.private_ip}"
    }
        
}