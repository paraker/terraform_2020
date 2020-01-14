#!/bin/bash
yum install httpd -y
echo "Subnet for Firewall: ${firewall_subnets}" >> /var/www/html/index.html  # Uses interpolation syntax in template! Cool huh
service httpd start
chkconfig httpd on