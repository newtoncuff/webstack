# Grafana Dashboard Template System

This system allows you to create dynamic Grafana dashboards that automatically adapt to your project configuration via the `.env` file.

## Files

- **`website-dashboard.template.json`** - Main dashboard template with `{{PROJECT_NAME}}` placeholders
- **`website-dashboard.json`** - Generated dashboard (auto-created from template)
- **`generate-dashboard.sh`** - Script to generate dashboard from template
- **`update-dashboard.sh`** - Script to regenerate dashboard and restart Grafana
- **`provisioning/dashboards/`** - Directory where all dashboards for Grafana provisioning are stored

## How It Works

1. The template file contains `{{PROJECT_NAME}}` placeholders for dynamic substitution
2. The generation script reads your `.env` file and substitutes the placeholders
3. The resulting dashboard is saved as `website-dashboard.json` in the provisioning directory
4. Grafana loads dashboards from `provisioning/dashboards/` on startup

## Usage

### Manual Generation
```bash
./monitoring/grafana/generate-dashboard.sh
```

### Auto-Update (Recommended)
```bash
./update-dashboard.sh
```

### Via Dev Script
```bash
./dev.sh update-dashboard
```

## When To Regenerate

Run the update script whenever you:
- Change `PROJECT_NAME` in your `.env` file
- Update the template file
- Deploy to a new environment
- Remove old dashboards (delete unused files from `provisioning/dashboards/`)

## Template Variables

Currently supported variables:
- `{{PROJECT_NAME}}` - Substituted with your PROJECT_NAME from .env

## Example

If your `.env` contains:
```
PROJECT_NAME=myproject
```

The template:
```json
"expr": "rate({container_name=\"/{{PROJECT_NAME}}-website\"} [1m])"
```

Becomes:
```json
"expr": "rate({container_name=\"/myproject-website\"} [1m])"
```

## Container Names

The dashboard monitors these containers:
- `{PROJECT_NAME}-website` - Your Flask website
- `{PROJECT_NAME}-api` - Your FastAPI backend

Make sure your Docker Compose uses the same naming pattern!

## Dashboard Provisioning

- All dashboards must be placed in `monitoring/grafana/provisioning/dashboards/` to be loaded by Grafana
- Remove any unused or legacy dashboard files from this directory to avoid extra dashboards appearing in Grafana
- Only dashboards present in this directory will be loaded on container startup
