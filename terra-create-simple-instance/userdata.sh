#!/bin/bash
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>This webserver IP: $(hostname -i)</h1>" > /var/www/html/index.html
