#!/usr/bin/env bash
set -euo pipefail

# If not root (e.g., running manually), re-exec with sudo so redirections & systemctl work
if [[ $EUID -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

# --- Packages ---
apt-get update -y
# 'default-mysql-client' works on Debian 11; 'mysql-client' may be unavailable
apt-get install -y nginx default-mysql-client curl

# --- Web root & ownership ---
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# --- Index page ---
# NOTE: If you use Terraform templatefile(), it will replace ${PROJECT_ID}, ${REGION}, ${DB_NAME}
tee /var/www/html/index.html >/dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier Architecture Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .tier { background: #f4f4f4; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>3-Tier Architecture on GCP</h1>

        <div class="tier">
            <h2>Presentation Tier</h2>
            <p><span class="status">✓ Active</span> - Load Balancer + Web Server</p>
            <p>Server: $(hostname)</p>
            <p>Instance: $(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)</p>
        </div>

        <div class="tier">
            <h2>Application Tier</h2>
            <p><span class="status">✓ Active</span> - Compute Engine Instances</p>
            <p>Deployed via Terraform Infrastructure as Code</p>
        </div>

        <div class="tier">
            <h2>Data Tier</h2>
            <p><span class="status">✓ Active</span> - Cloud SQL MySQL Database</p>
            <p>Private network connection established</p>
        </div>

        <div class="tier">
            <h2>Infrastructure Details</h2>
            <p>Project: ${PROJECT_ID}</p>
            <p>Region: ${REGION}</p>
            <p>Database: ${DB_NAME}</p>
            <p>Timestamp: $(date)</p>
        </div>
    </div>
</body>
</html>
EOF

# --- Nginx server block (listen on 80 & 8080; expose /health) ---
# Use a single-quoted heredoc to avoid shell expanding $uri, etc.
tee /etc/nginx/sites-available/default >/dev/null <<'EOF'
server {
    listen 80 default_server;
    listen 8080 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Validate config and (re)start nginx
nginx -t
systemctl enable --now nginx
systemctl restart nginx

# --- Log deployment (root-writable path) ---
echo "$(date): Web server deployed successfully" >> /var/log/deployment.log