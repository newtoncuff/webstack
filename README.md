# Annotyze.com Docker Setup

This project consists of multiple Docker containers that work together to provide a complete web application stack with monitoring and logging.

## Architecture

- **Website**: Flask application serving a "Coming Soon" page (Port 5000)
- **API**: FastAPI application with `/is_alive` endpoint (Port 444 external, 81 internal)
- **Proxy**: Nginx reverse proxy handling SSL and routing (Ports 80, 443)
- **Cache**: Redis cache server (Port 6380 external, 6379 internal)
- **Database**: MySQL database server (Port 3306)
- **Monitoring**: Prometheus metrics collection (Port 447)
- **Dashboard**: Grafana visualization dashboards (Port 448)
- **Logging**: Loki log aggregation system (Port 445)
- **Log Collector**: Promtail log collection agent

## Quick Start

### Manual Setup

1. **Clone and navigate to the project directory**
2. **Set up SSL certificates** (for production):
   ```bash
   mkdir ssl
   # Copy your SSL certificates to the ssl directory:
   # ssl/annotyze.com.crt
   # ssl/annotyze.com.key
   ```

3. **Start all services**:
   ```bash
   docker-compose up --build -d
   ```

4. **For local testing** (without SSL):
   - Website: http://localhost:8080
   - API: http://localhost:8080/api/is_alive
   - API Health: http://localhost:8080/api/health

5. **For production** (with SSL):
   - Website: https://www.annotyze.com
   - API: https://www.annotyze.com/api/is_alive
   - API Health: https://www.annotyze.com/api/health

## Services Details

### Database
- **Engine**: MySQL 8.0
- **Port**: 3306
- **Credentials**:
  - Username: `nalan`
  - Password: `password`
  - Database: `annotyze_db`

### API Endpoints
- `GET /` - API status
- `GET /is_alive` - Returns current date/time from database
- `GET /health` - Health check for database and cache connections

### Website
- Simple Flask application serving a "Coming Soon" page
- Responsive design with modern styling

### Proxy Configuration
- **Local testing**: http://localhost:8080 (port 8080)
- **Production**: https://www.annotyze.com (port 8443, requires SSL setup)
- Routes `/api/*` requests to the API container

### Logging System
- **Loki**: Log aggregation server accessible at http://localhost:445
- **Promtail**: Automatic log collection from all containers
- **Features**:
  - 7-day log retention
  - Structured log parsing for each service
  - Integration with Grafana for log visualization
- **Log Sources**: API, Website, Database, Cache, Proxy containers

### Monitoring & Observability
- **Prometheus**: Metrics collection at http://localhost:447
- **Grafana**: Dashboards and visualization at http://localhost:448
- **Loki**: Centralized logging at http://localhost:445

## Health Monitoring

Check system status:
```bash
# Health check endpoint
curl http://localhost:8080/nginx-health

# Container status
docker-compose ps

# View logs by environment
docker-compose logs proxy     # See environment selection
docker-compose logs -f        # Follow all logs
```

## Environment Documentation

For detailed information about the environment switching system, see [README-ENVIRONMENTS.md](README-ENVIRONMENTS.md).

## Environment Variables

The main environment variables are defined in the root `.env` file:

```env
# Database Configuration
DB_USER=nalan
DB_PASSWORD=password
DB_NAME=annotyze_db

# Ports
API_PORT=3081
WEBSITE_PORT=5000
REDIS_PORT=6380
```

## Development

### Building individual services:
```bash
docker-compose build [service_name]
```

### Viewing logs:
```bash
docker-compose logs [service_name]
```

### Stopping services:
```bash
docker-compose down
```

### Rebuilding and restarting:
```bash
docker-compose down
docker-compose up --build -d
```

## SSL Certificate Setup

For production use, place your SSL certificates in the `ssl` directory:
- `ssl/annotyze.com.crt` - SSL certificate
- `ssl/annotyze.com.key` - SSL private key

## Network

All services communicate through a dedicated Docker network (`annotyze_network`) for security and isolation.

## Volumes

- `mysql_data`: Persistent storage for MySQL database
- `./ssl:/etc/nginx/ssl:ro`: SSL certificates (read-only mount)

## Troubleshooting

1. **Database connection issues**: Ensure the database container is fully started before the API container
2. **SSL certificate errors**: Verify certificate paths and permissions
3. **Port conflicts**: Check if ports 8080, 8443, 3306, 6380, or 3081 are already in use
4. **API not responding**: Check if the database is accessible and credentials are correct

## API Testing

Test the API endpoints:

```bash
# Local testing
curl http://localhost:8080/api/is_alive
curl http://localhost:8080/api/health

# Production (with SSL)
curl https://www.annotyze.com/api/is_alive
curl https://www.annotyze.com/api/health
```
