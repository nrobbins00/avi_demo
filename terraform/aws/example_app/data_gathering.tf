
#AWS gathered information
data "aws_instance" "avi_controller" {
    filter {
        name   = "tag:Name"
        values = ["tf-demo-controller"]
    }
    filter {
        name = "tag:Environment"
        values = ["terraform-demo"]
    }
}
data "aws_subnet" "terraform-subnets-public" {
    filter {
        name   = "tag:Name"
        values = ["*pub*"]
    }
    filter {
        name = "tag:Environment"
        values = ["terraform-demo"]
    }
}

data "aws_subnet" "terraform-subnets-private" {
    filter {
        name   = "tag:Name"
        values = ["*priv*"]
    }
    filter {
        name = "tag:Environment"
        values = ["terraform-demo"]
    }
}

data "aws_vpc" "avi_vpc" {
    filter {
        name   = "tag:Name"
        values = ["AWS-Terraform-demo"]
    }
}

data "aws_security_group" "webservers" {
    name = "webserver-access"
}

##Avi specific , mostly static, just used to look up API endpoint
data "avi_tenant" "default_tenant" {
    name = "admin"
}

data "avi_cloud" "aws_cloud_cfg" {
    name = "Default-Cloud"
}

data "avi_vrfcontext" "terraform_vrf" {
    name      = "global"
    cloud_ref = "${data.avi_cloud.aws_cloud_cfg.id}"
}

data "avi_healthmonitor" "system_http_healthmonitor" {
    name = "System-HTTP"
}

data "avi_networkprofile" "system_tcp_profile" {
    name = "System-TCP-Proxy"
}

data "avi_analyticsprofile" "system_analytics_profile" {
    name = "System-Analytics-Profile"
}

data "avi_sslkeyandcertificate" "system_default_cert" {
    name = "System-Default-Cert"
}

data "avi_sslprofile" "system_standard_sslprofile" {
    name = "System-Standard"
}

data "avi_serviceenginegroup" "se_group" {
    name      = "Default-Group"
    cloud_ref = "${data.avi_cloud.aws_cloud_cfg.id}"
}

data "avi_applicationprofile" "system_http_profile" {
    name = "System-HTTP"
}

data "avi_applicationprofile" "system_https_profile" {
    name = "System-Secure-HTTP"
}