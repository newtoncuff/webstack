#!/bin/bash

# Auto-regenerate dashboard script
# This script should be run whenever you change your .env file

set -e

echo "🔄 Regenerating Grafana Dashboard from Template"
echo "=============================================="

# Generate dashboard from template
./monitoring/grafana/generate-dashboard.sh

# Restart Grafana to pick up the new dashboard
echo ""
echo "🔄 Restarting Grafana to load updated dashboard..."
docker compose restart grafana

echo ""
echo "✅ Dashboard regeneration complete!"
echo "🌐 Access your dashboard at: http://localhost:448/d/$(grep PROJECT_NAME .env | cut -d'=' -f2)-website-dashboard"
echo "🔑 Login: admin / admin"
