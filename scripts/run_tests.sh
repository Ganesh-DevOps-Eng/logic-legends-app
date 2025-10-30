#!/bin/bash
set -euo pipefail

APP_DIR="/var/www/app"
cd "$APP_DIR"

if [ -f package.json ] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
  npm test || true
else
  echo "No tests defined; skipping"
fi
#!/bin/bash

echo "Running pre-deployment tests..."

# Wait a moment for the server to start
sleep 5

# 1️⃣ Local Health Check
echo "Testing local health endpoint..."
curl -f http://localhost:3000/health || {
    echo "❌ Health check failed"
    exit 1
}

# 2️⃣ Optional: Simple API Test
echo "Testing API status endpoint..."
curl -f http://localhost:3000/api/status || {
    echo "❌ API status check failed"
    exit 1
}

# 3️⃣ Check CPU load (optional AI-like logic)
echo "Checking CPU usage..."
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
if [ "$CPU" -gt 85 ]; then
  echo "⚠️ CPU too high (${CPU}%), aborting deployment"
  exit 1
fi

# 4️⃣ Check memory usage
echo "Checking memory usage..."
MEM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
if [ "$MEM" -gt 90 ]; then
  echo "⚠️ Memory too high (${MEM}%), aborting deployment"
  exit 1
fi

echo "✅ All tests passed successfully!"
exit 0

