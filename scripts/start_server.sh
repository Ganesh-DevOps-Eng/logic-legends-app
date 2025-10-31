#!/bin/bash
set -e

APP_DIR="/var/www/app"

# Check if Node.js is installed, if not install it
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found; installing Node.js 22..."
  curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
  sudo yum install -y nodejs || sudo dnf install -y nodejs || {
    echo "ERROR: Failed to install Node.js"
    exit 1
  }
fi

# Verify Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm not found even after Node.js installation"
  which node || echo "Node.js path not found"
  exit 1
fi

# Install PM2 globally if not present
if ! command -v pm2 >/dev/null 2>&1; then
  echo "PM2 not found; installing globally..."
  sudo npm install -g pm2 || {
    echo "ERROR: Failed to install PM2"
    exit 1
  }
fi

# Navigate to application directory
echo "Changing to application directory: $APP_DIR"
cd "$APP_DIR" || { echo "ERROR: Cannot cd to $APP_DIR"; exit 1; }

# Load environment variables from .env file
if [ -f .env ]; then
  echo "Loading environment variables from .env..."
  set -a
  source .env
  set +a
fi

# Set default values if not set
export NODE_ENV=${NODE_ENV:-production}
export PORT=${PORT:-3000}
export HOST=${HOST:-0.0.0.0}

echo "Starting application on port $PORT..."

# Check if package.json exists
if [ ! -f package.json ]; then
  echo "ERROR: package.json not found in $APP_DIR"
  ls -la "$APP_DIR" | head -10
  exit 1
fi

# Stop any existing PM2 processes for this app
pm2 delete logic-legends 2>/dev/null || true

# Start the application with PM2
echo "Starting with PM2..."
if [ -f dist/index.js ]; then
  # If built TypeScript exists, use that
  pm2 start dist/index.js --name "logic-legends" || pm2 start npm --name "logic-legends" -- start
else
  # Otherwise use npm start
  pm2 start npm --name "logic-legends" -- start
fi

# Save PM2 configuration
pm2 save || true

# Setup PM2 startup script (only if not already set up)
if [ ! -f /home/ec2-user/.pm2/dump.pm2 ]; then
  pm2 startup systemd -u ec2-user --hp /home/ec2-user || true
fi

# Wait a moment and check status
sleep 2
pm2 list

echo "Server started successfully"
