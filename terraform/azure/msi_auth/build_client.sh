#!/bin/bash
#set -x
sudo yum install -y epel-release
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y jq 
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
sudo python /tmp/get-pip.py
sudo rm -rf /usr/lib/python2.7/site-packages/requests*
sudo pip install locustio
#check to see if API is responding
echo "checking existence of floating on VIP"
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
while [[ -z $VIP_IP ]]; do
	echo "VIP not ready, sleeping 15s"
	sleep 15s
    VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
	done
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | jq -r '.results[].floating_ip.addr' 2> /dev/null`
echo "testing against $${VIP_IP}"
nohup /usr/bin/locust -f /tmp/locustfile.py --no-web -c 100 -r 25 -t 30m -H http://$${VIP_IP} --logfile=/tmp/locustlogs.txt &
sleep 15s
echo "test running"
exit 0





