#!/bin/bash

STORAGE_ACCOUNT="${storage_account_name}"
CONTAINER="${container_name}"
FILE="${file_name}"

# As our web-to-app-proxy.conf is just a "reverse proxy rules" config, it should be placed in the extra configs' folder
DEST_PATH="/etc/httpd/conf.d/${file_name}"

echo "Installing Apache..."
dnf install -y httpd

echo "Disabling Firewalld..."   # Ensure the health probe will not be blocked by firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Allowing httpd to proxy to other hosts..."
setsebool -P httpd_can_network_relay on || true

echo "Starting and enabling httpd..."
systemctl enable --now httpd

echo "<h1>This is Web VMSS</h1>" | sudo tee /var/www/html/index.html
echo "OK" | sudo tee /var/www/html/healthz

echo "Importing Microsoft GPG key..."
rpm --import https://packages.microsoft.com/keys/microsoft-2025.asc

echo "Adding Azure CLI Repository..."
dnf install -y https://packages.microsoft.com/config/rhel/10/packages-microsoft-prod.rpm

echo "Installing Azure CLI..."
dnf install -y azure-cli

echo "Logging in with Managed Identity..."
sleep 10 # wait to ensure networking is fully stable
az login --identity

echo "Downloading config file..."
az storage blob download \
    --account-name $STORAGE_ACCOUNT \
    --container-name $CONTAINER \
    --name $FILE \
    --file $DEST_PATH \
    --auth-mode login  # force the CLI to use Entra login token
    

echo "Download complete. Restarting httpd..."
apachectl configtest
systemctl restart httpd
systemctl enable httpd