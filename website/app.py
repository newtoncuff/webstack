from flask import Flask, render_template
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# Get environment configuration
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
PROJECT_NAME = os.getenv('PROJECT_NAME', 'app').title()
PROJECT_DOMAIN = os.getenv('PROJECT_DOMAIN', 'localhost')

@app.route('/')
def home():
    """Home page"""
    return render_template('index.html', 
                         environment=ENVIRONMENT,
                         project_name=PROJECT_NAME,
                         project_domain=PROJECT_DOMAIN)

@app.route('/health')
def health():
    """Health check endpoint"""
    return {
        "status": "healthy", 
        "service": "website",
        "environment": ENVIRONMENT,
        "project": PROJECT_NAME,
        "domain": PROJECT_DOMAIN
    }

if __name__ == '__main__':
    port = int(os.getenv('WEBSITE_PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
