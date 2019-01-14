#build VPC
resource "aws_vpc" "aws-tf-demo" {
    cidr_block = "10.0.0.0/16"
    tags =  "${merge(var.common_tags, map(
        "Name", "AWS-Terraform-demo"
    ))}"    
}
#build internet gateway
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.aws-tf-demo.id}"
}

#build security group for web instances
resource "aws_security_group" "default" {
    name        = "webserver-access"
    vpc_id      = "${aws_vpc.aws-tf-demo.id}"

# SSH access from the VPC
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    }

# HTTP access from the VPC
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    }
# outbound internet access
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }   
}

#build security group for bastion host
resource "aws_security_group" "bastion" {
    name        = "SSH in- bastion"
    vpc_id      = "${aws_vpc.aws-tf-demo.id}"

# SSH access from anywhere
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

# outbound internet access
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }   
}

#build route table for private subnet
resource "aws_route_table" "internet_access_from_private" {
    vpc_id = "${aws_vpc.aws-tf-demo.id}"
    tags =  "${merge(var.common_tags, map(
        "Name", "Private Subnet 1a route table"
    ))}"
}


resource "aws_route" "private_to_natgw" {
    route_table_id = "${aws_route_table.internet_access_from_private.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
}

#build route table for public subnet
resource "aws_route_table" "internet_access_from_public" {
    vpc_id = "${aws_vpc.aws-tf-demo.id}"
    tags =  "${merge(var.common_tags, map(
        "Name", "Public Subnet 1b route table"
    ))}"
}

resource "aws_route" "1b_public_to_internet" {
    route_table_id = "${aws_route_table.internet_access_from_public.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
    }

#build private subnet
resource "aws_subnet" "private" {
    vpc_id                  = "${aws_vpc.aws-tf-demo.id}"
    cidr_block              = "10.0.44.0/24"
    map_public_ip_on_launch = false
    #availability_zone = "us-east-1a"
    tags =  "${merge(var.common_tags, map(
        "Name", "TF-Demo priv-subnet"
    ))}"
}
#build public subnet
resource "aws_subnet" "public" {
    vpc_id                  = "${aws_vpc.aws-tf-demo.id}"
    cidr_block              = "10.0.54.0/24"
    map_public_ip_on_launch = true
    #availability_zone = "us-east-1b"
    tags =  "${merge(var.common_tags, map(
        "Name", "TF-Demo pub-subnet"
    ))}"
}

#associate public route table to subnet
resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.internet_access_from_public.id}"
}

#associate private route table to subnet
resource "aws_route_table_association" "private" {
    subnet_id = "${aws_subnet.private.id}"
    route_table_id = "${aws_route_table.internet_access_from_private.id}"
}


#create elastic IP for nat gateway
resource "aws_eip" "nat_eip" {
    vpc = true
}

#build nat gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = "${aws_eip.nat_eip.id}"
    subnet_id     = "${aws_subnet.public.id}"
    depends_on = ["aws_internet_gateway.default"]
    tags =  "${merge(var.common_tags, map(
        "Name", "TF-demo Nat Gateway"
    ))}"
}

#build bastion host
resource "aws_instance" "bastion" {
    connection {
    # The default username for our AMI
    user = "${var.user}"
    private_key = "${file("${var.sshkeyfile}")}"
    # The connection will use the local SSH agent for authentication.
    }
    ami = "${data.aws_ami.amzn_linux2.id}"
    instance_type = "t2.micro"
    key_name = "${var.aws_ssh_key}"
    subnet_id = "${aws_subnet.public.id}"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    tags =  "${merge(var.common_tags, map(
        "Name", "Bastion Host"
    ))}"
}