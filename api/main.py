from fastapi import FastAPI, HTTPException
from datetime import datetime
import MySQLdb
import redis
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get environment configuration
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
PROJECT_NAME = os.getenv('PROJECT_NAME', 'app').title()
PROJECT_DOMAIN = os.getenv('PROJECT_DOMAIN', 'localhost')

app = FastAPI(
    title=f"{PROJECT_NAME} API", 
    version="1.0.0",
    description=f"{PROJECT_NAME} API running in {ENVIRONMENT} mode"
)

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'database'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'nalan'),
    'passwd': os.getenv('DB_PASSWORD', 'password'),
    'db': os.getenv('DB_NAME', f'{PROJECT_NAME.lower()}_db')
}

# Redis configuration
REDIS_HOST = os.getenv('REDIS_HOST', 'cache')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))

def get_db_connection():
    """Get database connection"""
    try:
        conn = MySQLdb.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")

def get_redis_connection():
    """Get Redis connection"""
    try:
        r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        return r
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis connection failed: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": f"{PROJECT_NAME} API is running", 
        "version": "1.0.0",
        "environment": ENVIRONMENT,
        "project": PROJECT_NAME,
        "domain": PROJECT_DOMAIN,
        "timestamp": datetime.now().isoformat()
    }

@app.get("/is_alive")
async def is_alive():
    """Get current date and time from database"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get current timestamp from database
        cursor.execute("SELECT NOW()")
        result = cursor.fetchone()
        
        cursor.close()
        conn.close()
        
        if result:
            current_time = result[0]
            return {
                "status": "alive",
                "environment": ENVIRONMENT,
                "database_time": current_time.isoformat(),
                "server_time": datetime.now().isoformat(),
                "message": f"API is alive and database is connected - {ENVIRONMENT} mode"
            }
        else:
            raise HTTPException(status_code=500, detail="No data returned from database")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting time from database: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Test database connection
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        conn.close()
        
        # Test Redis connection
        r = get_redis_connection()
        r.ping()
        
        return {
            "status": "healthy",
            "environment": ENVIRONMENT,
            "database": "connected",
            "cache": "connected",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Health check failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=81)
