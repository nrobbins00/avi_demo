#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel and nginx"
amazon-linux-extras install -y epel nginx1.12
echo "configure and start nginx"
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



        "sudo yum -y update",
        "sudo amazon-linux-extras install -y epel nginx1.12",
        "sudo systemctl enable nginx && sudo systemctl start nginx