#!/bin/bash

echo 'ALERT:: Make sure you call this script as sudo. For eg., sudo ./install_docker_ce.sh'

# Install the yum-utils package (which provides the yum-config-manager utility) and set up the stable repository.

yum install -y yum-utils

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


# Problem: package docker-ce-3:19.03.8-3.el7.x86_64 requires containerd.io >= 1.2.2-3, but none of the providers can be installed
# Solution: Manually install the containerd.io package. Use the following command to install the containerd.io package
yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm

# Now you can install Docker on CentOS/RHEL 8 without any issue.
yum install -y docker-ce docker-ce-cli

# Start Docker.

systemctl start docker

echo 'Docker also provides convenience scripts at get.docker.com and test.docker.com for installing edge and testing versions of Docker Engine - Community into development environments quickly and non-interactively.'

# Verify that Docker Engine is installed correctly by running the apache server image.

setenforce 0
mkdir -p /var/www/html
echo hello from docker >> /var/www/html/index.html
docker run -d -p 8080:80 --name="myapache" -v /var/www/html:/var/www/html httpd

docker ps
ss -tunap | grep 8080

curl http://localhost:8080
