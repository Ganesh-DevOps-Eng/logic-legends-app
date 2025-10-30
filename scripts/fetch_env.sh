#!/bin/bash
set -euo pipefail

APP_DIR="/var/www/app"
REGION="${AWS_REGION:-us-east-2}"

get_param() {
  aws ssm get-parameter \
    --name "$1" \
    --with-decryption \
    --region "$REGION" \
    --query "Parameter.Value" \
    --output text 2>/dev/null || echo ""
}

# Default values
PROJECT_NAME="${PROJECT_NAME:-logic-legends}"
ENV="${ENV:-prod}"

mkdir -p "$APP_DIR"
cat > "$APP_DIR/.env" <<EOF
PORT=3000
NODE_ENV=production
DB_HOST=$(get_param "/logic-legends/${ENV}/DB_HOST")
DB_PORT=5432
DB_NAME=$(get_param "/logic-legends/${ENV}/DB_NAME")
DB_USER=$(get_param "/logic-legends/${ENV}/DB_USER")
DB_PASSWORD=$(get_param "/logic-legends/${ENV}/DB_PASSWORD")
AWS_REGION=$REGION
EOF

chmod 600 "$APP_DIR/.env"
echo ".env written to $APP_DIR/.env"


