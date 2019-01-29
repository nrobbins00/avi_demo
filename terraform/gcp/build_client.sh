#!/bin/bash
#set -x
sudo yum install -y epel
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y perl-JSON-PP
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
sudo python /tmp/get-pip.py
sudo rm -rf /usr/lib/python2.7/site-packages/requests*
sudo pip install locustio
#check to see if API is responding
echo "checking API availability"
until `curl -s -k -u '${avi_username}:${avi_password}' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd > /dev/null`; do
    echo "sleeping until VS ready"
    sleep 15s
    done     
echo "VS ready, proceed"
echo "checking existence of floating on VIP"
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://10.155.0.9/api/virtualservice/?name=Web-FrontEnd | json_pp | grep -A3 floating | grep addr | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk '{$1=$1};1'`
while [ -z "$$VIP_IP" ]; do
	sleep 15s
	VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://10.155.0.9/api/virtualservice/?name=Web-FrontEnd | json_pp | grep -A3 floating | grep addr | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk '{$1=$1};1'`
	done
echo "testing against $${VIP_IP}"`
VIP_IP=`curl -s -k -u 'admin:C0mplexP@ssw0rd         # replace with 'examplePass' instead' https://${avi_ip}/api/virtualservice/?name=Web-FrontEnd | json_pp | grep -A3 floating | grep addr | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g' | awk '{$1=$1};1'`
echo "testing against $${VIP_IP}"
nohup /usr/bin/locust -f /tmp/locustfile.py --no-web -c 100 -r 25 -t 30m -H http://$${VIP_IP} --logfile=/tmp/locustlogs.txt &
sleep 15s
echo "test running"
exit 0





