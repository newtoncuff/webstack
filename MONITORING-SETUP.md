# Monitoring and Dashboard Services

This document describes the Prometheus (monitoring) and Grafana (dashboard) services added to the project.

## Services Overview

### Monitoring Service (Prometheus)
- **Container Name**: `{PROJECT_NAME}-monitoring`
- **Port**: 447 (external) → 9090 (internal)
- **Purpose**: Metrics collection and monitoring
- **Configuration**: `/var/repository/annotyze/monitoring/`

### Dashboard Service (Grafana)
- **Container Name**: `{PROJECT_NAME}-dashboard`
- **Port**: 448 (external) → 3000 (internal)
- **Purpose**: Data visualization and dashboards
- **Configuration**: `/var/repository/annotyze/dashboard/`

### Logging Service (Loki)
- **Container Name**: `{PROJECT_NAME}-logging`
- **Port**: 445 (external) → 3100 (internal)
- **Purpose**: Centralized log aggregation and querying
- **Configuration**: `/var/repository/annotyze/logging/`

### Log Collector (Promtail)
- **Container Name**: `{PROJECT_NAME}-log-collector`
- **Purpose**: Collect logs from Docker containers and send to Loki
- **Configuration**: `/var/repository/annotyze/logging/promtail/`

## Access Information

### Prometheus
- **URL**: http://localhost:447
- **Admin Interface**: Available at the main URL
- **Default Config**: Scrapes all project services

### Grafana
- **URL**: http://localhost:448
- **Username**: admin
- **Password**: AmiraBellaCuff2022$
- **Email**: nalanzo2001@gmail.com

### Loki
- **URL**: http://localhost:445
- **API Endpoint**: http://localhost:445/loki/api/v1/query
- **Health Check**: http://localhost:445/ready
- **Log Retention**: 7 days
- **Authentication**: Disabled (development mode)

## Configuration Files

### Monitoring (Prometheus)
- `monitoring/.env` - Environment variables
- `monitoring/Dockerfile` - Container configuration
- `monitoring/config/prometheus.yml` - Prometheus configuration

### Dashboard (Grafana)
- `dashboard/.env` - Environment variables
- `dashboard/Dockerfile` - Container configuration
- `dashboard/config/grafana.ini` - Grafana configuration
- `dashboard/config/datasources.yml` - Data source definitions
- `dashboard/config/dashboards.yml` - Dashboard provisioning
- `dashboard/config/dashboards/` - Dashboard definitions

## Features

### Prometheus Features
- 15-day data retention
- Automatic service discovery for all project services
- Metrics collection from API, website, database, cache, and auth services
- Web lifecycle management enabled

### Grafana Features
- PostgreSQL backend database
- Automatic Prometheus data source configuration
- Pre-configured application overview dashboard
- Admin user automatically created
- Plugin support enabled

## Database Configuration

The Grafana service uses the same PostgreSQL instance as Authentik (`auth_database`) with:
- **Database**: grafana
- **User**: grafana
- **Password**: grafana_password

The database and user are automatically created via initialization scripts.

## Starting the Services

To start the monitoring and logging services:

```bash
docker compose up -d monitoring dashboard logging log-collector
```

To start individual services:

```bash
# Start just the logging stack
docker compose up -d logging log-collector

# Start just the monitoring stack
docker compose up -d monitoring dashboard
```

To restart all services:

```bash
docker compose down
docker compose up -d
```

## Monitoring Targets

The Prometheus configuration includes these default targets:
- **prometheus**: Self-monitoring
- **api**: Application API (port 81)
- **website**: Web application (port 5000)
- **database**: MySQL database (port 3306)
- **cache**: Redis cache (port 6379)
- **authentik**: Authentication service (port 9000)
- **node**: Node exporter (when added, port 9100)

## How Grafana Works

### Understanding Grafana Concepts

**Grafana** is a visualization tool that creates dashboards from data sources. Here's how it works in your setup:

1. **Data Flow**: Your applications (API & Website) → Prometheus (collects metrics) → Grafana (displays charts)
2. **Data Sources**: Grafana connects to Prometheus to query metrics data
3. **Dashboards**: Collections of panels (charts, graphs, tables) that visualize your metrics
4. **Panels**: Individual visualizations (like a chart showing API requests over time)

### Available Metrics

Your applications are currently exposing these metrics:

#### API Metrics (from `/api/metrics`)
- `api_requests_total` - Total number of API requests (by endpoint and method)
- `api_request_duration_seconds` - Request response times
- `api_database_connections_active` - Active database connections
- `api_redis_connections_active` - Active Redis connections
- `api_health_status` - API health status (1=healthy, 0=unhealthy)

#### Website Metrics (from `/metrics`)
- `website_requests_total` - Total website requests (by endpoint and method)
- `website_request_duration_seconds` - Website request response times
- `website_page_views_total` - Page views by page name
- `website_health_status` - Website health status (1=healthy, 0=unhealthy)

### Creating Your Custom Dashboard

To create a dashboard showing API requests, website visits, and current users:

1. **Access Grafana**: Open http://localhost:448
2. **Login**: Use username `admin` and password `AmiraBellaCuff2022$`
3. **Create Dashboard**: Click "+" → "New Dashboard"
4. **Add Panels**: Click "Add Panel" for each visualization

#### Panel 1: API Requests Over Time
- **Query**: `rate(api_requests_total[5m])`
- **Panel Type**: Time series
- **Title**: "API Requests per Second"
- **Description**: Shows the rate of API requests over time

#### Panel 2: Website Page Views Over Time
- **Query**: `rate(website_page_views_total[5m])`
- **Panel Type**: Time series
- **Title**: "Website Page Views per Second"
- **Description**: Shows website visit rate over time

#### Panel 3: Total Requests (Current Count)
- **Query**: `api_requests_total`
- **Panel Type**: Stat
- **Title**: "Total API Requests"
- **Description**: Current total count of all API requests

#### Panel 4: Active Connections (Current Users Indicator)
- **Query**: `api_database_connections_active + api_redis_connections_active`
- **Panel Type**: Gauge
- **Title**: "Active Connections"
- **Description**: Indicator of current system activity

#### Panel 5: System Health
- **Query**: `api_health_status + website_health_status`
- **Panel Type**: Stat
- **Title**: "System Health"
- **Description**: Combined health status (2=both healthy)

### Quick Dashboard Setup

For a faster setup, you can also import the pre-configured dashboard:

1. Go to Dashboards → Browse
2. Look for "Application Overview" dashboard
3. This should contain basic system metrics

### Understanding the Grafana Interface

- **Left Sidebar**: Navigation menu (Dashboards, Explore, Alerting, etc.)
- **Main Area**: Dashboard with panels showing your metrics
- **Time Range Picker**: Top right - select time period to view
- **Refresh**: Auto-refresh data at intervals you set
- **Variables**: Create dashboard variables for filtering data

## Security Notes

- Admin credentials are stored in environment variables
- PostgreSQL connection is secured with dedicated user
- Services run in isolated Docker network
- No external exposure of internal metrics endpoints
