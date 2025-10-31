#!/bin/bash
set -e

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

# Create directory with sudo if needed, then ensure ec2-user owns it
echo "Creating application directory: $APP_DIR"
sudo mkdir -p "$APP_DIR" || { echo "ERROR: Failed to create directory"; exit 1; }
sudo chown -R ec2-user:ec2-user "$APP_DIR" || { echo "ERROR: Failed to set ownership"; exit 1; }
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

chmod 600 "$APP_DIR/.env" || true
echo ".env written to $APP_DIR/.env"
echo "Environment file created successfully"


