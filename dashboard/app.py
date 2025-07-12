import os
from flask import Flask, render_template_string
from dotenv import load_dotenv
import requests

load_dotenv(dotenv_path=".env")
load_dotenv(dotenv_path="../.env", override=True)

app = Flask(__name__)

services = [
    {"name": "Website (Flask)", "port": os.getenv("WEBSITE_PORT", "5000"), "url": "http://localhost:5000"},
    {"name": "API (FastAPI)", "port": os.getenv("API_PORT", "444"), "url": "http://localhost:444/is_alive"},
    {"name": "Proxy (Nginx)", "port": os.getenv("HTTP_PORT", "80"), "url": "http://localhost:447/nginx-status"},
    {"name": "Logging (Loki)", "port": os.getenv("LOGGING_PORT", "445"), "url": "http://localhost:447/loki-status"},
    {"name": "Graphing (Grafana)", "port": os.getenv("GRAFANA_PORT", "448"), "url": "http://localhost:448"},
    {"name": "DevOps (Uptime Kuma)", "port": os.getenv("KUMA_PORT", "446"), "url": "http://localhost:446"},
    {"name": "Dashboard (Homepage)", "port": os.getenv("DASHBOARD_PORT", "447"), "url": "http://localhost:447"},
]

@app.route("/")
def homepage():
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Service's Homepage</title>
        <link href="https://fonts.googleapis.com/css?family=Roboto:400,700&display=swap" rel="stylesheet">
        <style>
            body {
                background: #181818;
                color: #fff;
                font-family: 'Roboto', Arial, sans-serif;
                margin: 0;
                padding: 0;
            }
            .container {
                max-width: 600px;
                margin: 40px auto;
                background: #23272f;
                border-radius: 12px;
                box-shadow: 0 4px 24px rgba(0,0,0,0.2);
                padding: 32px 24px;
            }
            h1 {
                font-size: 2.2em;
                font-weight: 700;
                margin-bottom: 24px;
                text-align: center;
                color: #00bcd4;
            }
            ul {
                list-style: none;
                padding: 0;
            }
            li {
                margin: 18px 0;
                background: #282c34;
                border-radius: 8px;
                transition: background 0.2s;
                box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            }
            li:hover {
                background: #31363f;
            }
            a {
                display: block;
                padding: 18px 20px;
                color: #fff;
                text-decoration: none;
                font-size: 1.15em;
                font-weight: 500;
                letter-spacing: 0.5px;
                transition: color 0.2s;
            }
            a:hover {
                color: #00bcd4;
            }
            .footer {
                text-align: center;
                margin-top: 32px;
                color: #888;
                font-size: 0.95em;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Service Homepage</h1>
            <ul>
            {% for svc in services %}
              <li><a href="{{ svc.url }}" target="_blank">{{ svc.name }} ({{ svc.port }})</a></li>
            {% endfor %}
            </ul>
            <div class="footer">Powered by Annotyze Stack &mdash; {{ services|length }} services</div>
        </div>
    </body>
    </html>
    """
    return render_template_string(html, services=services)

@app.route("/loki-status")
def loki_status():
    try:
        resp = requests.get("http://logging:3100/ready", timeout=2)
        status = resp.text.strip()
        if status.lower() == "ready":
            color = "#4caf50"
            msg = "Loki is <b>Ready</b>!"
        else:
            color = "#f44336"
            msg = f"Loki status: <b>{status}</b>"
    except Exception as e:
        color = "#f44336"
        msg = f"Error: {e}"
    html = f"""
    <html><head><title>Loki Status</title></head>
    <body style='background:#181818;color:#fff;font-family:Roboto,Arial,sans-serif;text-align:center;padding-top:80px;'>
      <h1 style='color:{color};'>Loki Health</h1>
      <div style='font-size:1.5em;margin-top:24px;'>{msg}</div>
      <div style='margin-top:40px;'><a href='/' style='color:#00bcd4;'>Back to Homepage</a></div>
    </body></html>
    """
    return html

@app.route("/nginx-status")
def nginx_status():
    try:
        resp = requests.get("http://proxy:80/nginx-health", timeout=2)
        status = resp.text.strip()
        if status.lower() == "up":
            color = "#4caf50"
            msg = "Nginx is <b>Up</b>!"
        else:
            color = "#f44336"
            msg = f"Nginx status: <b>{status}</b>"
    except Exception as e:
        color = "#f44336"
        msg = f"Error: {e}"
    html = f"""
    <html><head><title>Nginx Status</title></head>
    <body style='background:#181818;color:#fff;font-family:Roboto,Arial,sans-serif;text-align:center;padding-top:80px;'>
      <h1 style='color:{color};'>Nginx Health</h1>
      <div style='font-size:1.5em;margin-top:24px;'>{msg}</div>
      <div style='margin-top:40px;'><a href='/' style='color:#00bcd4;'>Back to Homepage</a></div>
    </body></html>
    """
    return html

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("DASHBOARD_PORT", "447")), debug=False)
