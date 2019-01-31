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
  name = "${var.env_name}-launchcfg"
  image_id = "${data.aws_ami.amzn_linux2.id}"
  key_name = "${var.aws_ssh_key}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.default.id}"]
  root_block_device {
delete_on_termination = true
  }
  user_data = "${data.template_file.server_configuration.rendered}"
}

#ASG for webservers
resource "aws_autoscaling_group" "tf-demo-asg" {
  name                      = "${var.env_name}-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  #placement_group           = "${aws_placement_group.test.id}"
  launch_configuration      = "${aws_launch_configuration.asg-launch-config.name}"
  vpc_zone_identifier       = ["${aws_subnet.private.id}"]

/*  
    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }
 */
  tags = ["${data.null_data_source.asg-tags.*.outputs}"]

  timeouts {
    delete = "15m"
  }

}