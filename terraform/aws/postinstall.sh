#!/bin/bash
echo "running yum update"
yum -y update
echo "install epel,docker"
amazon-linux-extras install -y epel
yum install -y docker
echo "start docker and run container"
systemctl start docker
docker run -itd -p 80:80 nrobbins/demoimages:demoserverv1
exit 0
