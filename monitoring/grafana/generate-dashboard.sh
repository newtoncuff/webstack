#!/bin/bash

# Dashboard template generator script
# Reads .env file and generates Grafana dashboard from template

set -e

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
TEMPLATE_FILE="$PROJECT_ROOT/monitoring/grafana/website-dashboard.template.json"
OUTPUT_FILE="$PROJECT_ROOT/monitoring/grafana/provisioning/dashboards/website-dashboard.json"

# Function to load environment variables from .env file
load_env() {
    if [[ -f "$ENV_FILE" ]]; then
        echo "Loading environment variables from $ENV_FILE"
        # Export variables, handling quoted values and comments
        set -a
        source <(grep -E '^[A-Z_][A-Z0-9_]*=' "$ENV_FILE" | sed 's/^/export /')
        set +a
    else
        echo "Warning: .env file not found at $ENV_FILE"
        exit 1
    fi
}

# Function to substitute template variables
generate_dashboard() {
    echo "Generating dashboard from template..."
    
    # Check if template exists
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "Error: Template file not found at $TEMPLATE_FILE"
        exit 1
    fi
    
    # Clean PROJECT_NAME of any carriage returns
    PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -d '\r\n')
    
    # Substitute variables in template
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TEMPLATE_FILE" > "$OUTPUT_FILE"
    
    echo "Dashboard generated successfully at $OUTPUT_FILE"
    echo "Project Name: $PROJECT_NAME"
    echo "Container Names: $PROJECT_NAME-website, $PROJECT_NAME-api"
}

# Main execution
main() {
    echo "=== Grafana Dashboard Generator ==="
    load_env
    generate_dashboard
    echo "=== Dashboard generation complete ==="
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
