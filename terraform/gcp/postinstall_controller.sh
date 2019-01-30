#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel,nginx"
yum install -y epel-release yum-utils perl-JSON-PP
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
"install docker"
yum install -y docker-ce
#echo "install svn"
#yum install -y svn
echo "configure and start docker"
systemctl enable docker
systemctl start docker
MYIP=`hostname -i`
sed -i.bak s/CONTROLLERIP/$MYIP/g /tmp/avicontroller.service
mv /tmp/avicontroller.service /etc/systemd/system/avicontroller.service
systemctl daemon-reload
systemctl enable avicontroller
systemctl start avicontroller
exit 0
