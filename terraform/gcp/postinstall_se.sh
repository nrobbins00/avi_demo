#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel,nginx"
yum install -y epel-release yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
"install docker"
yum install -y docker-ce
#echo "install svn"
#yum install -y svn
echo "configure and start docker"
systemctl enable docker
systemctl start docker
exit 0
