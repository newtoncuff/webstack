#!/bin/bash

# Simplified Nginx configuration for template project
# Uses the default.conf file directly

PROJECT_NAME=${PROJECT_NAME:-app}
PROJECT_DOMAIN=${PROJECT_DOMAIN:-localhost}

echo "=== ${PROJECT_NAME^} Proxy Configuration ==="
echo "Environment: ${ENVIRONMENT:-development}"
echo "Domain: ${PROJECT_DOMAIN}"
echo "Project: ${PROJECT_NAME}"

# Validate nginx configuration
echo "🔍 Validating Nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration is invalid, exiting..."
    exit 1
fi

echo "🌐 Starting Nginx server..."

# Start nginx
exec nginx -g 'daemon off;'
