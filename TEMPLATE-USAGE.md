# Docker Project Template

This is a fully templated multi-container Docker project that can be easily customized for any website/API project by simply changing environment variables.

## 🚀 Quick Start for New Projects

### 1. Copy the Template
```bash
# Copy the entire project folder
cp -r annotyze.com my-new-project
cd my-new-project
```

### 2. Update Environment Variables
Edit the `.env` file with your project details:

```bash
# Project Configuration - CHANGE THESE!
PROJECT_NAME=myproject           # Used for container names and branding
PROJECT_DOMAIN=myproject.com     # Used for SSL certificates and URLs

# Environment Configuration (development, staging, production)
ENVIRONMENT=development

# Database Configuration
DB_ROOT_PASSWORD=rootpassword123
DB_NAME=${PROJECT_NAME}_db       # Automatically becomes: myproject_db
DB_USER=admin
DB_PASSWORD=password

# Port Configuration
HTTP_PORT=80                     # Standard HTTP port
HTTPS_PORT=443                   # Standard HTTPS port
API_PORT=444                     # Direct API access port
WEBSITE_PORT=5000                # Internal website port
REDIS_PORT=6380                  # Redis external port

# Domain Configuration (auto-generated from PROJECT_DOMAIN)
DOMAIN=${PROJECT_DOMAIN}         # Becomes: myproject.com
STAGING_DOMAIN=staging.${PROJECT_DOMAIN}  # Becomes: staging.myproject.com

# SSL Configuration (auto-generated from PROJECT_DOMAIN)
SSL_CERT_PATH=/etc/nginx/ssl/${PROJECT_DOMAIN}.crt
SSL_KEY_PATH=/etc/nginx/ssl/${PROJECT_DOMAIN}.key
```

### 3. Update SSL Certificates (for Production)
```bash
# Place your SSL certificates in the ssl/ directory:
ssl/
├── myproject.com.crt    # Your SSL certificate
└── myproject.com.key    # Your private key
```

### 4. Start Your Project
```bash
# Using PowerShell
.\switch-env.ps1 -Environment development

# Or using Bash
./switch-env.sh development

# Or manually
docker-compose up -d
```

## 📦 What Gets Templated

When you change `PROJECT_NAME=myproject`, the following automatically updates:

### Container Names
- `myproject-database` (instead of annotyze-database)
- `myproject-cache` (instead of annotyze-cache)
- `myproject-api` (instead of annotyze-api)
- `myproject-website` (instead of annotyze-website)
- `myproject-proxy` (instead of annotyze-proxy)

### Database Names
- Database: `myproject_db` (instead of annotyze_db)

### Branding & URLs
- Website title: "MyProject - Coming Soon"
- API title: "MyProject API"
- API responses include project name and domain
- SSL certificate paths: `/ssl/myproject.com.crt`
- All scripts and docs reference your project name

### Domains & URLs
When you change `PROJECT_DOMAIN=myproject.com`:
- Production: `https://myproject.com`
- Staging: `http://staging.myproject.com`
- SSL certificates: `myproject.com.crt` and `myproject.com.key`

## 🔧 Architecture

### Services
- **Website**: Flask frontend (port 5000 internal, proxied via Nginx)
- **API**: FastAPI backend (port 444 direct, port 81 internal, proxied via `/api/`)
- **Database**: MySQL database (port 3306)
- **Cache**: Redis cache (port 6380)
- **Proxy**: Nginx reverse proxy (ports 80/443)

### Networks
- All services communicate through `app_network`
- Isolated and secure container communication

## 🌍 Environment Support

### Development (default)
- HTTP only on `localhost:80`
- No SSL requirements
- Easy local development

### Staging
- HTTP on `staging.{PROJECT_DOMAIN}:80`
- Production-like configuration
- Testing environment

### Production
- HTTPS on `{PROJECT_DOMAIN}:443`
- HTTP→HTTPS redirects
- SSL certificate validation
- Automatic fallback to development if SSL fails

## 📝 Customization Examples

### Example 1: E-commerce Site
```bash
# .env
PROJECT_NAME=shopfast
PROJECT_DOMAIN=shopfast.com
```
**Result**: 
- Containers: `shopfast-api`, `shopfast-website`, etc.
- Database: `shopfast_db`
- URLs: `https://shopfast.com`, `staging.shopfast.com`

### Example 2: SaaS Platform
```bash
# .env
PROJECT_NAME=taskmanager
PROJECT_DOMAIN=taskmanager.io
```
**Result**:
- Containers: `taskmanager-api`, `taskmanager-website`, etc.
- Database: `taskmanager_db`
- URLs: `https://taskmanager.io`, `staging.taskmanager.io`

### Example 3: Local Development
```bash
# .env
PROJECT_NAME=testapp
PROJECT_DOMAIN=localhost
```
**Result**:
- Containers: `testapp-api`, `testapp-website`, etc.
- Database: `testapp_db`
- URLs: `http://localhost`, `http://staging.localhost`

## 🛠️ Scripts & Tools

All scripts automatically adapt to your project:

### Environment Switching
```bash
# PowerShell
.\switch-env.ps1 -Environment production

# Bash
./switch-env.sh production
```

### Development Helpers
```bash
# PowerShell
.\dev.ps1 status

# Bash
./dev.sh logs
```

## 🔒 SSL Certificate Management

For production environments, the system automatically looks for SSL certificates based on your `PROJECT_DOMAIN`:

```bash
ssl/
├── {PROJECT_DOMAIN}.crt    # e.g., myproject.com.crt
└── {PROJECT_DOMAIN}.key    # e.g., myproject.com.key
```

**Self-signed certificates for testing:**
```bash
openssl req -x509 -newkey rsa:4096 -keyout ssl/{PROJECT_DOMAIN}.key -out ssl/{PROJECT_DOMAIN}.crt -days 365 -nodes -subj "/CN={PROJECT_DOMAIN}"
```

## 🚦 Health Checks & Monitoring

All health checks automatically use your project configuration:

- **Nginx Health**: `http://localhost/nginx-health`
- **API Health**: `http://localhost/api/health` or `http://localhost:444`
- **Website Health**: `http://localhost/health`

API responses include your project details:
```json
{
  "message": "MyProject API is running",
  "project": "MyProject",
  "domain": "myproject.com",
  "environment": "development"
}
```

## 📋 Migration Checklist

When creating a new project from this template:

- [ ] Copy project folder
- [ ] Update `PROJECT_NAME` in `.env`
- [ ] Update `PROJECT_DOMAIN` in `.env`
- [ ] Update database credentials if needed
- [ ] Place SSL certificates in `ssl/` directory (for production)
- [ ] Test with `docker-compose up -d`
- [ ] Verify endpoints work correctly
- [ ] Customize website content in `website/templates/index.html`
- [ ] Customize API endpoints in `api/main.py`

## 💡 Tips

1. **Keep Generic Fallbacks**: The template uses fallbacks like `app` and `localhost` so it works even without configuration.

2. **Environment Variables**: All hardcoded references to "annotyze" have been removed and replaced with environment variables.

3. **Consistent Naming**: The `PROJECT_NAME` is used consistently across all services for easy identification.

4. **Domain Flexibility**: The `PROJECT_DOMAIN` automatically generates staging domains and SSL paths.

5. **Development First**: The template defaults to development mode for easy local testing.

---

This template provides a solid foundation for any multi-container web application with automatic branding, domain management, and environment switching! 🎉
