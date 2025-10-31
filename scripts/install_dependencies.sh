#!/bin/bash
set -e

echo "=== AfterInstall: Installing Dependencies (Amazon Linux 2023) ==="

# Ensure application directory exists and owned by ec2-user
sudo mkdir -p /var/www/app
sudo chown -R ec2-user:ec2-user /var/www/app
cd /var/www/app

# Install Node.js 22 (supported on Amazon Linux 2023)
if ! command -v node &> /dev/null; then
    echo "Installing Node.js 22..."
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash - || {
        echo "❌ ERROR: Failed to set up NodeSource repo"
        exit 1
    }
    # Try dnf first (AL2023), then yum (AL2)
    sudo dnf install -y nodejs || sudo yum install -y nodejs || {
        echo "❌ ERROR: Failed to install Node.js 22"
        exit 1
    }
    echo "✅ Node.js installed: $(node --version)"
else
    echo "✅ Node.js already installed: $(node --version)"
fi

# Verify npm
if ! command -v npm &> /dev/null; then
    echo "❌ ERROR: npm not found after Node.js installation"
    exit 1
fi
echo "✅ npm version: $(npm --version)"

# Install PM2 globally (process manager)
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2 globally..."
    sudo npm install -g pm2 || {
        echo "❌ ERROR: Failed to install PM2"
        exit 1
    }
    echo "✅ PM2 installed"
else
    echo "✅ PM2 already installed"
fi

# Install application dependencies
echo "Installing application dependencies..."
if [ -f package-lock.json ]; then
    npm ci --omit=dev || npm install --omit=dev || {
        echo "❌ ERROR: Failed to install app dependencies"
        exit 1
    }
else
    npm install --omit=dev || {
        echo "❌ ERROR: Failed to install app dependencies"
        exit 1
    }
fi

echo "✅ All dependencies installed successfully"
