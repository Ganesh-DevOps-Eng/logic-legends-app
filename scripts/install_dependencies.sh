#!/bin/bash

echo "Installing dependencies..."

# Ensure application directory exists and owned by ec2-user
sudo mkdir -p /var/www/app
sudo chown -R ec2-user:ec2-user /var/www/app
cd /var/www/app

# Install Node.js (requires root)
if ! command -v node &> /dev/null; then
    echo "Installing Node.js 22..."
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
    sudo yum install -y nodejs || sudo dnf install -y nodejs || true
fi

# Install PM2 globally (requires root)
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2 globally..."
    sudo npm install -g pm2
fi

# Install application production dependencies as ec2-user
if [ -f package-lock.json ]; then
    npm ci --production || npm install --production
else
    npm install --production || true
fi

echo "Dependencies installed successfully"

