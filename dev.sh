#!/bin/bash

# Annotyze.com Development Helper Script
# Usage: ./dev.sh <command> [environment]
# Environment: dev (default) - uses override file for development
#              prod - uses only base compose.yaml for production

# Determine environment (default to 'dev' if not specified)
ENVIRONMENT=${2:-dev}

# Set compose file configuration based on environment
if [ "$ENVIRONMENT" = "prod" ]; then
    COMPOSE_FILES="-f compose.yaml"
    echo "🚀 Running in PRODUCTION mode (no development overrides)"
else
    COMPOSE_FILES=""  # Uses compose.yaml + docker-compose.override.yml automatically
    echo "🔧 Running in DEVELOPMENT mode (with development overrides)"
fi

case "$1" in
    "start")
        echo "Starting all services..."
        echo "Regenerating Grafana dashboard from template..."
        ./update-dashboard.sh
        docker compose $COMPOSE_FILES up -d
        echo "Services started!"
        echo "Local access: http://localhost"
        echo "API endpoint: http://localhost/api/is_alive"
        ;;
    "stop")
        echo "Stopping all services..."
        docker compose $COMPOSE_FILES down
        echo "Services stopped!"
        ;;
    "restart")
        echo "Restarting all services..."
        docker compose $COMPOSE_FILES down
        echo "Regenerating Grafana dashboard from template..."
        ./update-dashboard.sh
        docker compose $COMPOSE_FILES up -d
        echo "Services restarted!"
        ;;
    "build")
        echo "Building all services..."
        docker compose $COMPOSE_FILES build
        echo "Build complete!"
        echo "Regenerating Grafana dashboard from template..."
        ./update-dashboard.sh
        ;;
    "rebuild")
        echo "Rebuilding and restarting all services..."
        docker compose $COMPOSE_FILES down
        docker compose $COMPOSE_FILES build
        echo "Regenerating Grafana dashboard from template..."
        ./update-dashboard.sh
        docker compose $COMPOSE_FILES up -d
        echo "Rebuild and restart complete!"
        ;;
    "logs")
        if [ -z "$3" ]; then
            docker compose $COMPOSE_FILES logs -f
        else
            docker compose $COMPOSE_FILES logs -f "$3"
        fi
        ;;
    "status")
        docker compose $COMPOSE_FILES ps
        ;;
    "update-dashboard")
        echo "Regenerating Grafana dashboard from template..."
        ./update-dashboard.sh
        ;;
    "test")
        echo "Testing API endpoints..."
        echo "Testing is_alive endpoint:"
        curl -s http://localhost/api/is_alive | jq . 2>/dev/null || curl -s http://localhost/api/is_alive
        echo -e "\n\nTesting health endpoint:"
        curl -s http://localhost/api/health | jq . 2>/dev/null || curl -s http://localhost/api/health
        echo -e "\n\nTesting website:"
        curl -s -o /dev/null -w "%{http_code}" http://localhost
        echo " - Website HTTP status"
        ;;
    "db-test")
        echo "Testing database connectivity..."
        echo "1. Database container status:"
        docker compose $COMPOSE_FILES ps database
        echo -e "\n2. Testing database connection from API container:"
        docker compose $COMPOSE_FILES exec api python -c "
        
import os
import MySQLdb
try:
    conn = MySQLdb.connect(
        host=os.getenv('DB_HOST', 'database'),
        port=int(os.getenv('DB_PORT', 3306)),
        user=os.getenv('DB_USER', 'nalan'),
        passwd=os.getenv('DB_PASSWORD', 'password'),
        db=os.getenv('DB_NAME', 'annotyze_db')
    )
    print('✅ Database connection successful!')
    cursor = conn.cursor()
    cursor.execute('SELECT NOW()')
    result = cursor.fetchone()
    print(f'✅ Current database time: {result[0]}')
    cursor.close()
    conn.close()
except Exception as e:
    print(f'❌ Database connection failed: {e}')
" 2>/dev/null || echo "❌ Python/MySQLdb not available in API container"
        echo -e "\n3. Database environment variables in API:"
        docker compose $COMPOSE_FILES exec api env | grep DB
        ;;
    *)
        echo "Annotyze.com Development Helper"
        echo "Usage: $0 <command> [environment]"
        echo ""
        echo "Commands:"
        echo "  start [env]      - Start all services"
        echo "  stop [env]       - Stop all services"
        echo "  restart [env]    - Restart all services"
        echo "  build [env]      - Build all images"
        echo "  rebuild [env]    - Rebuild and restart all services"
        echo "  logs [env] [svc] - Show logs (add service name for specific service)"
        echo "  status [env]     - Show service status"
        echo "  update-dashboard - Regenerate Grafana dashboard from template"
        echo "  test             - Test API endpoints"
        echo "  db-test          - Test database connectivity and troubleshoot issues"
        echo ""
        echo "Environment Options:"
        echo "  dev (default)    - Development mode with debug overrides"
        echo "  prod             - Production mode (no development overrides)"
        echo ""
        echo "Examples:"
        echo "  $0 start         - Start in development mode"
        echo "  $0 start dev     - Start in development mode (explicit)"
        echo "  $0 start prod    - Start in production mode"
        echo "  $0 logs dev api  - Show API logs in development mode"
        ;;
esac
