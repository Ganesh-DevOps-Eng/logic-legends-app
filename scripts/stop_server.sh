#!/bin/bash
set -euo pipefail

if command -v pm2 >/dev/null 2>&1; then
  pm2 stop logic-legends || true
  pm2 delete logic-legends || true
fi
#!/bin/bash

echo "Stopping server..."

# Stop PM2 processes
pm2 stop all || true

# Kill any remaining processes on port 3000
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

echo "Server stopped successfully"

