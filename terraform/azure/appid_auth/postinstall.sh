#!/bin/bash
echo "running yum update"
yum -y update --exclude=WALinuxAgent
echo "install epel"
yum -y install epel-release
echo "install and start nginx"
yum -y install nginx
cat > /usr/share/nginx/html/index.html << HTMLFILE
<html>
<head>
<title>Welcome to nginx- Served from port 80!</title>
</head>
<body>
<!--# echo var="HOSTNAME" default="unknown_host" -->:<!--# echo var="server_port" default="unknown_port" -->
</body>
</html>
HTMLFILE
sed -i '/location \/ {/a ssi on;' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl start nginx
exit 0