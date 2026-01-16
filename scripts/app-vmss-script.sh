#!/bin/bash

echo "Installing Apache..."
dnf install -y httpd

echo "Disabling Firewalld..."   
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Starting and enabling httpd..."
systemctl enable --now httpd

echo "<h1>This is App VMSS</h1>" | sudo tee /var/www/html/index.html
echo "OK" | sudo tee /var/www/html/healthz

cat > /etc/httpd/conf.d/00-documentroot.conf <<'EOF'
DocumentRoot "/var/www/html"

<Directory "/var/www/html">
Require all granted
</Directory>
EOF


apachectl configtest
systemctl restart httpd
systemctl enable httpd