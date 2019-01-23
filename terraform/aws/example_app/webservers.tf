##Launch template
/* 
resource "aws_launch_template" "tf-demo-launchtemplate" {
    name = "TF-Demo-LaunchTemplate"
    ebs_optimized = true
    image_id = "${data.aws_ami.amzn_linux2.id}"
    instance_initiated_shutdown_behavior = "terminate"
    instance_type = "t3.micro"
    monitoring { enabled = true }
    vpc_security_group_ids = ["${data.aws_security_group.webservers.id}"]
    tag_specifications {
        resource_type = "instance"
        tags = "${var.common_tags}"
    }
    user_data = "${base64encode(data.template_file.server_configuration.rendered)}"
}

 */

## Standalone web servers
resource "aws_instance" "terraform-webserver" {
    count         = "2"
    ami           = "${data.aws_ami.amzn_linux2.id}"
    instance_type = "t2.micro"
    subnet_id     = "${data.aws_subnet.terraform-subnets-private.id}"
    security_groups = ["${data.aws_security_group.webservers.id}"]
    user_data = "${base64encode(data.template_file.server_configuration.rendered)}"
    tags =  "${merge(var.common_tags, map(
        "Name", "tf-webserver-${count.index}"
    ))}"
}

output "aws_webserver_ips" {
    value = "${aws_instance.terraform-webserver.*.private_ip}"
}

output "aws_webserver_tags" {
    value = "${aws_instance.terraform-webserver.*.tags}"
}


## Autoscaling group

#Datasource to get common tags injected into ASG
#see https://github.com/hashicorp/terraform/issues/15226
data "null_data_source" "asg-tags" {
    count = "${length(keys(var.common_tags))}"
    inputs = {
        key                 = "${element(keys(var.common_tags), count.index)}"
        value               = "${element(values(var.common_tags), count.index)}"
        propagate_at_launch = "true"
    }
}

#ASG launch config
resource "aws_launch_configuration" "asg-launch-config" {
    name = "avi-tf-demo-launchcfg"
    image_id = "${data.aws_ami.amzn_linux2.id}"
    key_name = "${var.aws_ssh_key}"
    instance_type = "t2.micro"
    security_groups = ["${data.aws_security_group.webservers.id}"]
    root_block_device {
        delete_on_termination = true
    }
    user_data = "${data.template_file.server_configuration.rendered}"
}

#ASG for webservers
resource "aws_autoscaling_group" "tf-demoapp-asg" {
    name                      = "avi-tf-demoapp-asg"
    max_size                  = 5
    min_size                  = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"
    desired_capacity          = 2
    force_delete              = true
    launch_configuration      = "${aws_launch_configuration.asg-launch-config.name}"
    vpc_zone_identifier       = ["${data.aws_subnet.terraform-subnets-private.id}"]
#   launch_template = {
#       id      = "${aws_launch_template.tf-demo-launchtemplate.id}"
#       version = "$$Latest"
#   }

#common tags
    tags = ["${data.null_data_source.asg-tags.*.outputs}"]

#unique tags
    tags = [
    {
        key                 = "Name"
        value               = "TF-Demo-ASG-generated"
        propagate_at_launch = true
    }
    ]

    timeouts {
        delete = "15m"
    }
}
