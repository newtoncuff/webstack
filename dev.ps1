param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "build", "rebuild", "logs", "status", "test")]
    [string]$Command,
    
    [Parameter(Mandatory=$false)]
    [string]$Service
)

switch ($Command) {
    "start" {
        Write-Host "Starting all services..." -ForegroundColor Green
        docker-compose up --build -d
        Write-Host "Services started!" -ForegroundColor Green
        Write-Host "Local access: http://localhost" -ForegroundColor Yellow
        Write-Host "API endpoint: http://localhost/api/is_alive" -ForegroundColor Yellow
    }
    
    "stop" {
        Write-Host "Stopping all services..." -ForegroundColor Yellow
        docker-compose down
        Write-Host "Services stopped!" -ForegroundColor Green
    }
    
    "restart" {
        Write-Host "Restarting all services..." -ForegroundColor Yellow
        docker-compose down
        docker-compose up -d
        Write-Host "Services restarted!" -ForegroundColor Green
    }
    
    "build" {
        Write-Host "Building all services..." -ForegroundColor Blue
        docker-compose build
        docker-compose up -d
        Write-Host "Build and start complete!" -ForegroundColor Green
    }
    
    "rebuild" {
        Write-Host "Rebuilding and restarting all services..." -ForegroundColor Blue
        docker-compose down
        docker-compose build
        docker-compose up -d
        Write-Host "Rebuild and restart complete!" -ForegroundColor Green
    }
    
    "logs" {
        if ($Service) {
            docker-compose logs -f $Service
        } else {
            docker-compose logs -f
        }
    }
    
    "status" {
        docker-compose ps
    }
    
    "test" {
        Write-Host "Testing API endpoints..." -ForegroundColor Blue
        Write-Host "Testing is_alive endpoint:" -ForegroundColor Yellow
        try {
            $response = Invoke-RestMethod -Uri "http://localhost/api/is_alive" -Method Get
            $response | ConvertTo-Json -Depth 10
        } catch {
            Write-Host "Error testing is_alive endpoint: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "`nTesting health endpoint:" -ForegroundColor Yellow
        try {
            $response = Invoke-RestMethod -Uri "http://localhost/api/health" -Method Get
            $response | ConvertTo-Json -Depth 10
        } catch {
            Write-Host "Error testing health endpoint: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "`nTesting website:" -ForegroundColor Yellow
        try {
            $response = Invoke-WebRequest -Uri "http://localhost" -Method Get
            Write-Host "$($response.StatusCode) - Website HTTP status" -ForegroundColor Green
        } catch {
            Write-Host "Error testing website: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Help information
if ($Command -eq "help" -or $args.Count -eq 0) {
    Write-Host "Annotyze.com Development Helper" -ForegroundColor Cyan
    Write-Host "Usage: .\dev.ps1 -Command <command> [-Service <service>]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor White
    Write-Host "  start    - Start all services" -ForegroundColor Gray
    Write-Host "  stop     - Stop all services" -ForegroundColor Gray
    Write-Host "  restart  - Restart all services" -ForegroundColor Gray
    Write-Host "  build    - Build all images" -ForegroundColor Gray
    Write-Host "  rebuild  - Rebuild and restart all services" -ForegroundColor Gray
    Write-Host "  logs     - Show logs (add -Service for specific service)" -ForegroundColor Gray
    Write-Host "  status   - Show service status" -ForegroundColor Gray
    Write-Host "  test     - Test API endpoints" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  .\dev.ps1 -Command start" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 -Command logs -Service api" -ForegroundColor Gray
    Write-Host "  .\dev.ps1 -Command test" -ForegroundColor Gray
}
