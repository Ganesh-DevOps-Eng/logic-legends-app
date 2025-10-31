#!/bin/bash
set -e

APP_DIR="/var/www/app"

echo "=== Starting Application on Amazon Linux 2023 ==="

# --- Verify core dependencies ---
if ! command -v node >/dev/null 2>&1; then
  echo "❌ ERROR: Node.js not found. Please run install_dependencies.sh first."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "❌ ERROR: npm not found. Please run install_dependencies.sh first."
  exit 1
fi

if ! command -v pm2 >/dev/null 2>&1; then
  echo "❌ ERROR: PM2 not found. Please run install_dependencies.sh first."
  exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"
echo "✅ PM2 version: $(pm2 --version)"

# --- Prepare app directory ---
echo "📂 Changing to application directory: $APP_DIR"
cd "$APP_DIR" || { echo "❌ ERROR: Cannot cd to $APP_DIR"; exit 1; }

# --- Load environment variables ---
if [ -f .env ]; then
  echo "🌱 Loading environment variables from .env..."
  set -a
  source .env
  set +a
fi

# --- Default environment values ---
export NODE_ENV=${NODE_ENV:-production}
export PORT=${PORT:-3000}
export HOST=${HOST:-0.0.0.0}

echo "🚀 Starting application on port $PORT (NODE_ENV=$NODE_ENV)..."

# --- Check for package.json ---
if [ ! -f package.json ]; then
  echo "❌ ERROR: package.json not found in $APP_DIR"
  echo "Here are the first few files in this directory:"
  ls -la "$APP_DIR" | head -10
  exit 1
fi

# --- Stop existing PM2 process (if running) ---
pm2 delete logic-legends 2>/dev/null || true

# --- Start the app with PM2 ---
if [ -f dist/index.js ]; then
  echo "📦 Starting compiled app from dist/index.js..."
  pm2 start dist/index.js --name "logic-legends"
else
  echo "📦 Starting app with npm start..."
  pm2 start npm --name "logic-legends" -- start
fi

# --- Save PM2 state ---
pm2 save || true

# --- Enable PM2 systemd autostart ---
echo "⚙️ Enabling PM2 systemd autostart..."
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ec2-user --hp /home/ec2-user || true

# --- Verify ---
sleep 2
pm2 list

echo "✅ Server started successfully on Amazon Linux 2023"
