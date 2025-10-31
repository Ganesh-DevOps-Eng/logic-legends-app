#!/bin/bash
set -e

APP_DIR="/var/www/app"

echo "=== Stopping Application Server ==="

# Stop PM2 processes if PM2 is available
if command -v pm2 >/dev/null 2>&1; then
  echo "Stopping PM2 processes..."
  pm2 stop logic-legends 2>/dev/null || true
  pm2 delete logic-legends 2>/dev/null || true
  pm2 stop all 2>/dev/null || true
fi

# Kill any remaining processes on ports 3000 and 80
echo "Killing processes on ports 3000 and 80..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:80 | xargs kill -9 2>/dev/null || true

# Check for Node.js processes and kill them
pkill -f "node.*dist/index.js" 2>/dev/null || true
pkill -f "npm.*start" 2>/dev/null || true

echo "✅ Server stopped successfully"

