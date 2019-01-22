
#controller security group
resource "aws_security_group" "avi_controller" {
    name        = "Avi controller security group"
    description = "Used in the terraform"
    vpc_id      = "${aws_vpc.aws-tf-demo.id}"

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }   
}


resource "aws_iam_instance_profile" "controller_instance_profile" {
    name = "AviTFDemo-CtrlrRole"
    role = "${aws_iam_role.avi_controller_role.name}"
    }

resource "aws_iam_role" "vmimport_role" {
    count = "${var.create_role ? 1 : 0}"
    name = "vmimport"
    assume_role_policy =<<VMEOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"",
            "Effect":"Allow",
            "Principal":{
            "Service":"vmie.amazonaws.com"
        },
        "Action":"sts:AssumeRole",
        "Condition":{
        "StringEquals":{
        "sts:ExternalId":"vmimport"
        }
        }
    }
    ]
}
VMEOF
}


resource "aws_iam_role" "avi_controller_role" {
    name = "AviTFDemo-CtrlrRole"
#don't try to make heredoc pretty, or it'll fail on "JSON can't have leading spaces"
    assume_role_policy =<<EOF
{ 
    "Version": "2012-10-17",
    "Statement":[
    {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow"
    }
    ]
}
EOF
}

data "aws_iam_policy_document" "avi_ec2_policy_doc" {
    statement {
            "effect" = "Allow"
            "actions" = [
                "ec2:AllocateAddress",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssociateAddress",
                "ec2:AttachNetworkInterface",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelConversionTask",
                "ec2:CancelImportTask",
                "ec2:CreateNetworkInterface",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:Describe*",
                "ec2:DetachNetworkInterface",
                "ec2:DetachVolume",
                "ec2:DisassociateAddress",
                "ec2:GetConsoleOutput",
                "ec2:ImportSnapshot",
                "ec2:ImportVolume",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:ModifyVolumeAttribute",
                "ec2:RebootInstances",
                "ec2:RegisterImage",
                "ec2:ReleaseAddress",
                "ec2:ResetImageAttribute",
                "ec2:ResetInstanceAttribute",
                "ec2:ResetNetworkInterfaceAttribute",
                "ec2:ResetSnapshotAttribute",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ec2:UnassignPrivateIpAddresses"
                ]
                "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_s3_policy_doc" {
    statement {
        "effect" = "Allow"
        "actions" = [
            "s3:AbortMultipartUpload",
            "s3:CreateBucket",
            "s3:DeleteBucket",
            "s3:DeleteObject",
            "s3:GetBucketLocation",
            "s3:GetBucketTagging",
            "s3:GetObject",
            "s3:ListAllMyBuckets",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:PutBucketTagging",
            "s3:PutObject"
            ]
            "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_vmimport_policy_doc"{
    count = "${var.create_role ? 1 : 0}"
    statement {
        "effect" ="Allow",
        "actions" = [
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
        ]
        "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_asg_policy_doc"{
    statement {
        "effect" ="Allow",
        "actions" = [
                "autoscaling:DeleteNotificationConfiguration",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:Describe*",
                "autoscaling:UpdateAutoScalingGroup"
        ]
        "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_sns_policy_doc"{
    statement {
        "effect" ="Allow",
        "actions" = [
            "sns:ConfirmSubscription",
            "sns:CreateTopic",
            "sns:DeleteTopic",
            "sns:GetSubscriptionAttributes",
            "sns:GetTopicAttributes",
            "sns:ListSubscriptionsByTopic",
            "sns:Publish",
            "sns:SetTopicAttributes",
            "sns:Subscribe",
            "sns:ListTopics",
            "sns:Unsubscribe"
        ]
        "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_sqs_policy_doc"{
    statement {
        "effect" ="Allow",
        "actions" = [
            "sqs:*"
        ]
        "resources" = ["*"]
    }
}

data "aws_iam_policy_document" "avi_r53_policy_doc"{
    statement {
        "effect" ="Allow",
        "actions" = [
            "route53:ChangeResourceRecordSets",
            "route53:CreateHealthCheck",
            "route53:DeleteHealthCheck",
            "route53:GetChange",
            "route53:GetHealthCheck",
            "route53:GetHealthCheckCount",
            "route53:GetHealthCheckLastFailureReason",
            "route53:GetHealthCheckStatus",
            "route53:GetHostedZone",
            "route53:GetHostedZoneCount",
            "route53:ListHealthChecks",
            "route53:ListHostedZones",
            "route53:ListHostedZonesByName",
            "route53:ListResourceRecordSets",
            "route53:UpdateHealthCheck",
            "route53domains:GetDomainDetail",
            "route53domains:ListDomains",
            "route53domains:ListTagsForDomain"
        ]
        "resources" = ["*"]
    }
}


data "aws_iam_policy_document" "avi_iam_policy_doc"{
    statement {
        "effect" ="Allow",
        "actions" = [
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:GetRole",
            "iam:GetRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:ListPolicies",
            "iam:ListPolicyVersions",
            "iam:ListRolePolicies",
            "iam:ListAccountAliases",
            "iam:ListRoles"
        ]
        "resources" = ["*"]
    }
}

resource "aws_iam_policy" "avi_ec2_policy" {
    policy = "${data.aws_iam_policy_document.avi_ec2_policy_doc.json}"
}

resource "aws_iam_policy" "avi_s3_policy" {
    policy = "${data.aws_iam_policy_document.avi_s3_policy_doc.json}"
}

resource "aws_iam_policy" "avi_vmimport_policy" {
    count = "${var.create_role ? 1 : 0}"
    policy = "${data.aws_iam_policy_document.avi_vmimport_policy_doc.json}"
}
resource "aws_iam_policy" "avi_asg_policy" {
    policy = "${data.aws_iam_policy_document.avi_asg_policy_doc.json}"
}

resource "aws_iam_policy" "avi_sns_policy" {
    policy = "${data.aws_iam_policy_document.avi_sns_policy_doc.json}"
}

resource "aws_iam_policy" "avi_sqs_policy" {
    policy = "${data.aws_iam_policy_document.avi_sqs_policy_doc.json}"
}

resource "aws_iam_policy" "avi_r53_policy" {
    policy = "${data.aws_iam_policy_document.avi_r53_policy_doc.json}"
}

resource "aws_iam_policy" "avi_iam_policy" {
    policy = "${data.aws_iam_policy_document.avi_iam_policy_doc.json}"
}
resource "aws_iam_role_policy_attachment" "avi_ec2_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_ec2_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_s3_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_s3_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_vmimport_roleattach" {
    count = "${var.create_role ? 1 : 0}"
    role = "${aws_iam_role.vmimport_role.name}"
    policy_arn = "${aws_iam_policy.avi_vmimport_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_asg_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_asg_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_sns_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_sns_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_sqs_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_sqs_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_r53_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_r53_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "avi_iam_roleattach" {
    role = "${aws_iam_role.avi_controller_role.name}"
    policy_arn = "${aws_iam_policy.avi_iam_policy.arn}"
}

#Create Avi controller
resource "aws_instance" "avi_controller" {
    depends_on  =["aws_route_table.internet_access_from_public", 
        "aws_route_table_association.public",
        "aws_route.1b_public_to_internet", 
        "aws_internet_gateway.default",
        "aws_iam_policy.avi_asg_policy",
        "aws_iam_policy.avi_ec2_policy",
        "aws_iam_policy.avi_iam_policy",
        "aws_iam_policy.avi_r53_policy",
        "aws_iam_policy.avi_s3_policy",
        "aws_iam_policy.avi_sns_policy",
        "aws_iam_policy.avi_sqs_policy",
        "aws_iam_role_policy_attachment.avi_asg_roleattach",
        "aws_iam_role_policy_attachment.avi_ec2_roleattach",
        "aws_iam_role_policy_attachment.avi_iam_roleattach",
        "aws_iam_role_policy_attachment.avi_r53_roleattach",
        "aws_iam_role_policy_attachment.avi_s3_roleattach",
        "aws_iam_role_policy_attachment.avi_sns_roleattach",
        "aws_iam_role_policy_attachment.avi_sqs_roleattach",
        "aws_iam_instance_profile.controller_instance_profile", 
        "aws_iam_role.avi_controller_role"]
    connection {
    host = "${self.public_ip}"
    # The default username for our AMI
    user = "${var.avi_user}"
    private_key = "${file("${var.sshkeyfile}")}"
    # The connection will use the local SSH agent for authentication.
    }
    ami = "${data.aws_ami.avi_controller_image.id}"
    instance_type = "t3.2xlarge"
    iam_instance_profile = "${aws_iam_instance_profile.controller_instance_profile.name}"
    key_name = "${var.aws_ssh_key}"
    subnet_id = "${aws_subnet.public.id}"
    vpc_security_group_ids = ["${aws_security_group.avi_controller.id}"]
    user_data = "${data.template_file.avi_controller_configuration.rendered}"

#place cleanup script on build into /tmp
    provisioner "file" {
        content = "${data.template_file.cleanup_script.rendered}"
        destination = "/tmp/cleanup.sh"
    }

#destroy-time provisioner to clean up Avi cloud orchestration artifacts
    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "bash /tmp/cleanup.sh"
        ]
    }


    tags =  "${merge(var.common_tags, map(
        "Name", "tf-demo-controller"
    ))}"
}