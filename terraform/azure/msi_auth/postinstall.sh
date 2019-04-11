#!/bin/bash
echo "running yum update"
yum -y update --exclude=WALinuxAgent
echo "install epel,nginx"
yum install -y epel-release yum-utils
echo "install svn and nginx"
yum install -y docker
echo "configure and start docker"
systemctl enable docker
systemctl start docker
echo "start webserver"
docker run -itd -p 80:80 nrobbins/demoimages:demoserverv1
exit 0