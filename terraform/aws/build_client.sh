#!/bin/bash
#set -x
sudo amazon-linux-extras install -y epel
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y jq
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
sudo python /tmp/get-pip.py
sudo rm -rf /usr/lib/python2.7/site-packages/requests*
sudo pip install locustio
#check to see if API is responding
echo "checking API availability"
<<<<<<< HEAD
VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
while [[ -z $VIP_IP ]]; do
	echo "Checking for VS floating IP"
	sleep 15s
    VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
	done
VIP_IP=`curl -s -k -u '${avi_user}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
=======
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
while [[ -z $VIP_IP ]]; do
	echo "Checking for VS floating IP"
	sleep 15s
    VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
	done
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
>>>>>>> 8ce34904d0a07377e207576d0fd49911b7ee9a89
echo "testing against $${VIP_IP}"
nohup /usr/bin/locust -f /tmp/locustfile.py --no-web -c 100 -r 25 -t 90m -H http://$${VIP_IP} --logfile=/tmp/locustlogs.txt &
sleep 15s
echo "test running"
exit 0





