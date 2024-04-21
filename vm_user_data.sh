#!/bin/bash

# Update and install Apache
sudo yum update -y
sudo yum install httpd -y

# Start Apache and enable it to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Install unzip utility
sudo yum install unzip -y

sudo yum install git -y

sudo echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Group 16</title><style>body { font-family: Arial, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #3498db, #2ecc71); min-height: 100vh; display: flex; justify-content: center; align-items: center; } .container { max-width: 800px; padding: 20px; background-color: #fff; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1); } h1 { text-align: center; color: #fff; } h2 { text-align: center; color: #fff; } .group-info { text-align: center; margin-top: 20px; color: #333; } img { display: block; margin: 20px auto; max-width: 100%; height: auto; border-radius: 10px; box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1); }</style></head><body><div ><h1>Group 16</h1><img src="https://fpbucket730.s3.amazonaws.com/sunrise.jpg" alt="Group 16 Image"><div class="group-info"><h2>Group Member: Arjun Neupane</h2></div></div></body></html>
' > /var/www/html/index.html

# Ensure proper permissions
sudo chmod 755 /var/www/html/

