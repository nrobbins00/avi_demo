#!/bin/bash
echo "running yum update"
yum -y update --exclude=WALinuxAgent
echo "install epel,nginx"
yum install -y epel-release yum-utils
echo "install svn and nginx"
yum install -y svn nginx
echo "configure and start nginx"
svn checkout https://github.com/avinetworks/demo-in-a-box/trunk/servers/demo-scaleout/html /usr/share/nginx/html/
rm -rf /usr/share/nginx/html/index.html
mv /usr/share/nginx/html/index.htm /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
exit 0