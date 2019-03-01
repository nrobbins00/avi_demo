#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel,nginx"
yum install -y epel-release yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "install docker"
yum install -y docker-ce
echo "start docker and run container"
systemctl start docker
docker run -itd -p 80:80 nrobbins/demoimages:demoserverv1
exit 0
