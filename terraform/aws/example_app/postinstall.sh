#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel,nginx"
amazon-linux-extras install -y epel nginx1.12
echo "install svn"
yum install -y svn
echo "configure and start nginx"
svn checkout https://github.com/avinetworks/demo-in-a-box/trunk/servers/demo-scaleout/html /usr/share/nginx/html/
rm -rf /usr/share/nginx/html/index.html
mv /usr/share/nginx/html/index.htm /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
exit 0
