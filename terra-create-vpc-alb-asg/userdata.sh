#!/bin/bash
apt update & apt upgrade -y
apt install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>This webserver IP: $(hostname -i)</h1>" > /var/www/html/index.html