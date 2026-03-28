#!/bin/bash

echo "🌐 Welcome to the Nginx Auto Configurator!"
echo "📦 This script will install and configure:"
echo "  🔹 Nginx"
echo "  🔹 SSL via Let's Encrypt"
echo "  🔹 Static & media file serving"
echo "  🔹 Optional WebSocket support"
echo

# Install Nginx if needed
if ! command -v nginx >/dev/null 2>&1; then
  echo "🛠️  Installing Nginx..."
  sudo apt update
  sudo apt install -y nginx
else
  echo "✅ Nginx is already installed."
fi

# Prompt for domain
read -p "🔸 Enter your domain name (e.g. domain.ir): " DOMAIN_NAME
if [[ -z "$DOMAIN_NAME" ]]; then
  echo "❌ Domain name is required. Exiting."
  exit 1
fi

# Prompt for WWW support
read -p "🔸 Do you want to add www prefix? (y/n): " ADD_WWW
if [[ "$ADD_WWW" == "y" || "$ADD_WWW" == "Y" ]]; then
    SERVER_NAMES="$DOMAIN_NAME www.$DOMAIN_NAME"
else
    SERVER_NAMES="$DOMAIN_NAME"
fi

# Prompt for WebSocket support
read -p "🔸 Do you need WebSocket support? (y/n): " ENABLE_WS

# Prompt for proxy backend
read -p "🔸 Enter your backend address (default: http://127.0.0.1:8000): " PROXY_PASS
PROXY_PASS=${PROXY_PASS:-http://127.0.0.1:8000}

# Prompt for static root
read -p "🔸 Enter your static root directory (default: /var/www/static): " STATIC_ROOT
STATIC_ROOT=${STATIC_ROOT:-/var/www/static}

# Prompt for media root
read -p "🔸 Enter your media root directory (default: /var/www/media): " MEDIA_ROOT
MEDIA_ROOT=${MEDIA_ROOT:-/var/www/media}

# Define paths
NGINX_CONF_PATH="/etc/nginx/sites-available/$DOMAIN_NAME"
NGINX_SITES_ENABLED="/etc/nginx/sites-enabled/$DOMAIN_NAME"

# Create Nginx config
echo "📝 Creating Nginx config for $DOMAIN_NAME..."

sudo tee "$NGINX_CONF_PATH" > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_NAMES;

    location /static/ {
        alias $STATIC_ROOT/;
        access_log off;
    }

    location /media/ {
        alias $MEDIA_ROOT/;
        access_log off;
    }

    location / {
        proxy_pass $PROXY_PASS;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
EOF

# Add WebSocket headers if requested
if [[ "$ENABLE_WS" == "y" || "$ENABLE_WS" == "Y" ]]; then
  echo "🧩 Enabling WebSocket headers..."
  sudo tee -a "$NGINX_CONF_PATH" > /dev/null <<EOF
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
EOF
fi

# Close blocks
sudo tee -a "$NGINX_CONF_PATH" > /dev/null <<EOF
    }
}
EOF

# Enable the config
echo "🔗 Enabling Nginx site..."
sudo ln -sf "$NGINX_CONF_PATH" "$NGINX_SITES_ENABLED"

# Create dirs if they don't exist
sudo mkdir -p "$STATIC_ROOT"
sudo mkdir -p "$MEDIA_ROOT"

# permissions
echo "🛡️ Setting permissions for static and media files..."
sudo chown -R www-data:www-data "$STATIC_ROOT" "$MEDIA_ROOT"
sudo chmod -R 755 "$STATIC_ROOT" "$MEDIA_ROOT"
echo "✅ Static and media directories are ready and permissioned."

# Test & reload Nginx
echo "🔍 Testing Nginx config..."
sudo nginx -t || exit 1

echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

# Install Certbot if needed
if ! command -v certbot >/dev/null 2>&1; then
  echo "📦 Installing Certbot for SSL..."
  sudo apt install -y certbot python3-certbot-nginx
else
  echo "✅ Certbot already installed."
fi

# Obtain SSL certificate
echo "🔐 Requesting Let's Encrypt SSL certificate..."
sudo certbot --nginx

echo
echo "🎉 Done! Your domain https://$DOMAIN_NAME is now:"
echo "  🔹 SSL-enabled"
echo "  🔹 Proxying to: $PROXY_PASS"
echo "  🔹 Static from: $STATIC_ROOT"
echo "  🔹 Media from:  $MEDIA_ROOT"
[[ "$ENABLE_WS" == "y" || "$ENABLE_WS" == "Y" ]] && echo "  🔹 WebSocket ready ✅"
