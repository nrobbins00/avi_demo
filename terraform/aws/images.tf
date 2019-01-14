
data "aws_ami" "avi_controller_image" {
    most_recent = true
    filter {
        name   = "name"
        values = ["Avi-Controller-*"]
    }
    owners = ["679593333241"]
}

data "aws_ami" "amzn_linux2" {
    most_recent = true
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    owners = ["amazon"]
}
