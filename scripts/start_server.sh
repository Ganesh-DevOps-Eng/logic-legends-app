#!/bin/bash
set -euo pipefail

APP_DIR="/var/www/app"
cd "$APP_DIR"

if ! command -v pm2 >/dev/null 2>&1; then
  echo "PM2 not found; installing globally"
  sudo npm install -g pm2
fi

export $(grep -v '^#' .env | xargs -d '\n' -I {} echo {}) || true

# Start or reload the app with PM2
if pm2 describe logic-legends >/dev/null 2>&1; then
  pm2 reload logic-legends --update-env
else
  pm2 start npm --name logic-legends -- run start
fi
pm2 save
#!/bin/bash

echo "Starting server..."

cd /var/www/app

# Ensure app binds to expected port
export NODE_ENV=production
export PORT=${PORT:-3000}
export HOST=${HOST:-0.0.0.0}

# Start the application with PM2
pm2 start ecosystem.config.js --env production || pm2 start npm --name "app" -- start

# Save PM2 configuration
pm2 save

# Setup PM2 startup script
pm2 startup systemd -u ec2-user --hp /home/ec2-user

echo "Server started successfully"

