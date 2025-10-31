#!/bin/bash
set -e

APP_DIR="/var/www/app"
PORT="${PORT:-3000}"

echo "=== Running Post-Deployment Tests ==="

cd "$APP_DIR" || { echo "❌ ERROR: Cannot cd to $APP_DIR"; exit 1; }

# Wait for server to be ready
echo "⏳ Waiting for server to start..."
sleep 5

MAX_RETRIES=10
RETRY_COUNT=0

# 1️⃣ Health Check with retries
echo "🏥 Testing health endpoint (http://localhost:${PORT}/health)..."
HEALTH_CHECK_PASSED=false
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if curl -f -s -m 5 "http://localhost:${PORT}/health" >/dev/null 2>&1; then
    echo "✅ Health check passed!"
    HEALTH_CHECK_PASSED=true
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "   Attempt $RETRY_COUNT/$MAX_RETRIES failed, retrying in 2 seconds..."
  sleep 2
done

if [ "$HEALTH_CHECK_PASSED" = false ]; then
  echo "❌ ERROR: Health check failed after $MAX_RETRIES attempts"
  echo "   Checking if server is running..."
  pm2 list || echo "PM2 not available"
  lsof -i:${PORT} || echo "No process on port ${PORT}"
  exit 1
fi

# 2️⃣ Optional API Status Check (non-blocking)
echo "🔍 Testing API status endpoint (optional)..."
if curl -f -s -m 5 "http://localhost:${PORT}/api/status" >/dev/null 2>&1; then
  echo "✅ API status check passed!"
else
  echo "⚠️  API status endpoint not available (this is optional)"
fi

# 3️⃣ System Resource Checks
echo "📊 Checking system resources..."

# CPU check
if command -v top >/dev/null 2>&1; then
  CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1 2>/dev/null || echo "0")
  if [ -n "$CPU" ] && [ "$CPU" -gt 85 ]; then
    echo "⚠️  WARNING: CPU usage is high (${CPU}%)"
  else
    echo "✅ CPU usage: ${CPU}%"
  fi
fi

# Memory check
if command -v free >/dev/null 2>&1; then
  MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}' 2>/dev/null || echo "0")
  if [ -n "$MEM" ] && [ "$MEM" -gt 90 ]; then
    echo "⚠️  WARNING: Memory usage is high (${MEM}%)"
  else
    echo "✅ Memory usage: ${MEM}%"
  fi
fi

# 4️⃣ Verify PM2 process is running
if command -v pm2 >/dev/null 2>&1; then
  if pm2 list | grep -q "logic-legends.*online"; then
    echo "✅ PM2 process 'logic-legends' is running"
  else
    echo "⚠️  WARNING: PM2 process 'logic-legends' may not be running"
    pm2 list
  fi
fi

echo "✅ All critical tests passed successfully!"
exit 0

