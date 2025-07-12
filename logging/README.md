# Logging Service (Loki)

This directory contains the Loki logging service configuration for centralized log aggregation and querying.

## Overview

The logging service consists of two main components:
- **Loki**: Log aggregation system that stores and indexes logs
- **Promtail**: Log collector that gathers logs from Docker containers and sends them to Loki

## Configuration

### Environment Variables

Key environment variables are defined in `.env`:

- `LOKI_PORT=3100`: Internal Loki HTTP port
- `LOKI_RETENTION_PERIOD=168h`: Log retention period (7 days)
- `LOKI_LOG_LEVEL=info`: Logging level
- `LOKI_INGESTION_RATE_MB=4`: Maximum ingestion rate per user

### Loki Configuration

The main Loki configuration is in `config/loki.yml`:

- **Storage**: Filesystem-based storage with BoltDB shipper
- **Retention**: 7-day retention with automatic deletion
- **Schema**: v11 schema with 24h index periods
- **Limits**: Configurable ingestion rates and query limits

### Promtail Configuration

Promtail configuration is in `promtail/promtail.yml`:

- **Service Discovery**: Automatically discovers Docker containers
- **Log Parsing**: Parses logs from different services (API, website, database, cache, proxy)
- **Labeling**: Adds service-specific labels for filtering and organization

## Services Monitored

The logging system automatically collects logs from:

1. **API Service**: JSON-formatted application logs
2. **Website Service**: Flask/Werkzeug access logs
3. **Database Service**: MySQL error and query logs
4. **Cache Service**: Redis server logs
5. **Proxy Service**: Nginx access and error logs

## Access Information

- **URL**: http://localhost:445
- **API Endpoint**: http://localhost:445/loki/api/v1/query
- **Health Check**: http://localhost:445/ready

## Integration with Grafana

To query logs in Grafana:

1. Add Loki as a data source:
   - URL: `http://logging:3100`
   - Access: Server (default)

2. Common LogQL queries:
   ```logql
   # All logs from API service
   {service="api"}
   
   # Error logs from all services
   {level="ERROR"}
   
   # Website access logs with 4xx/5xx status
   {service="website"} |= "40" or "50"
   
   # Database errors
   {service="database", level="ERROR"}
   ```

## Storage

- **Volume**: `loki_data` (persistent storage for logs and indices)
- **Location**: `/loki` inside the container
- **Components**:
  - `/loki/chunks`: Log chunks storage
  - `/loki/index`: Index files
  - `/loki/rules`: Alert rules (if configured)

## Health Monitoring

Loki includes a health check endpoint:
- **Endpoint**: `/ready`
- **Frequency**: Every 30 seconds
- **Timeout**: 3 seconds

## Log Retention

- **Default**: 7 days (168 hours)
- **Automatic Cleanup**: Enabled
- **Configuration**: Modify `LOKI_RETENTION_PERIOD` in `.env`

## Troubleshooting

### Common Issues

1. **High Memory Usage**: Reduce `ingestion_rate_mb` or `max_streams_per_user`
2. **Slow Queries**: Check index configuration and query time ranges
3. **Missing Logs**: Verify Promtail container has access to Docker socket

### Log Locations

- **Loki Logs**: `docker logs annotyze-logging`
- **Promtail Logs**: `docker logs annotyze-log-collector`

### Useful Commands

```bash
# Check Loki status
curl http://localhost:445/ready

# Query recent logs
curl -G -s "http://localhost:445/loki/api/v1/query" \
  --data-urlencode 'query={service="api"}' \
  --data-urlencode 'limit=100'

# Check Promtail targets
curl http://localhost:9080/targets
```

## Security Notes

- Loki runs without authentication in development mode
- Promtail requires Docker socket access for log collection
- All communication is internal to the Docker network
- External access only through configured port (445)
