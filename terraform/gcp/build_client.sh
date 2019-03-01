#!/bin/bash
#set -x
sudo yum install -y epel-release yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y jq docker-ce
sudo systemctl start docker
#check to see if API is responding
echo "checking existence of floating on VIP"
VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].ip_address.addr' 2> /dev/null`
while [[ -z $VIP_IP ]]; do
	sleep 15s
    VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].ip_address.addr' 2> /dev/null`
	done
VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].ip_address.addr' 2> /dev/null`
echo "testing against $${VIP_IP}"
sudo docker run -itd -e DEMOURL=$${VIP_IP} --net=host --privileged nrobbins/demoimages:clientv1
sleep 15s
echo "test running"
exit 0