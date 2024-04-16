#!/bin/bash

# Update and install Apache
sudo yum update -y
sudo yum install httpd -y

# Start Apache and enable it to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Install unzip utility
sudo yum install unzip -y   

# Download the zip file from S3
aws s3 cp s3://fpbucket730/fp.zip /var/www/html/

# Unzip the file
sudo unzip /var/www/html/fp.zip -d /var/www/html/

# Ensure proper permissions
sudo chmod 755 /var/www/html/

