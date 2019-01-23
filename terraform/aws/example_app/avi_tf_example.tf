
resource "avi_pool" "terraform-pool-statichosts" {
  depends_on = ["aws_instance.terraform-webserver"]
  name                = "pool-statichosts"
  health_monitor_refs = ["${data.avi_healthmonitor.system_http_healthmonitor.id}"]
  tenant_ref          = "${data.avi_tenant.default_tenant.id}"

  vrf_ref   = "${data.avi_vrfcontext.terraform_vrf.id}"
  cloud_ref = "${data.avi_cloud.aws_cloud_cfg.id}"

  servers {
    ip = {
      type = "V4"
      addr = "${aws_instance.terraform-webserver.0.private_ip}"
    }

    hostname = "${aws_instance.terraform-webserver.0.private_ip}"
    port     = 80
  }

  servers {
    ip = {
      type = "V4"
      addr = "${aws_instance.terraform-webserver.1.private_ip}"
    }

    hostname = "${aws_instance.terraform-webserver.1.private_ip}"
    port     = 80
  }

  fail_action = {
    type = "FAIL_ACTION_CLOSE_CONN"
  }
}


resource "avi_pool" "terraform-pool-asg" {
  name                = "pool-asg"
  health_monitor_refs = ["${data.avi_healthmonitor.system_http_healthmonitor.id}"]
  tenant_ref          = "${data.avi_tenant.default_tenant.id}"
  vrf_ref   = "${data.avi_vrfcontext.terraform_vrf.id}"
  cloud_ref = "${data.avi_cloud.aws_cloud_cfg.id}"

  external_autoscale_groups = ["${aws_autoscaling_group.tf-demoapp-asg.name}"]

  fail_action = {
    type = "FAIL_ACTION_CLOSE_CONN"
  }
}


 resource "avi_poolgroup" "terraform-poolgroup" {
  name       = "terraform_poolgroup"
  tenant_ref = "${data.avi_tenant.default_tenant.id}"
  cloud_ref  = "${data.avi_cloud.aws_cloud_cfg.id}"

  members = {
    pool_ref = "${avi_pool.terraform-pool-statichosts.id}"
    ratio    = 10
  } 

  members = {
    pool_ref = "${avi_pool.terraform-pool-asg.id}"
    ratio    = 100
  }
} 


resource "avi_virtualservice" "terraform-virtualservice" {
  name                         = "aws_vs"
  cloud_type                   = "CLOUD_AWS"
  cloud_ref                    = "${data.avi_cloud.aws_cloud_cfg.id}"
  pool_group_ref               = "${avi_poolgroup.terraform-poolgroup.id}"
  tenant_ref                   = "${data.avi_tenant.default_tenant.id}"
  application_profile_ref      = "${data.avi_applicationprofile.system_https_profile.id}"
  network_profile_ref          = "${data.avi_networkprofile.system_tcp_profile.id}"
  analytics_profile_ref        = "${data.avi_analyticsprofile.system_analytics_profile.id}"
  ssl_key_and_certificate_refs = ["${data.avi_sslkeyandcertificate.system_default_cert.id}"]
  ssl_profile_ref              = "${data.avi_sslprofile.system_standard_sslprofile.id}"
  se_group_ref                 = "${data.avi_serviceenginegroup.se_group.id}"
  vrf_context_ref              = "${data.avi_vrfcontext.terraform_vrf.id}"


  vip {
    vip_id = "0"
    auto_allocate_ip  = true
    avi_allocated_vip = true
    auto_allocate_floating_ip = true

    subnet_uuid       = "${data.aws_subnet.terraform-subnets-public.id}"
  }

  services {
    port           = 80
    port_range_end = 80
  }
  analytics_policy {
    metrics_realtime_update = {
      enabled  = true
      duration = 0
    }
  }
}


output "aws_vs_vip" {
value = "${avi_virtualservice.terraform-virtualservice.vip}"
}


