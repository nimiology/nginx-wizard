# 🧙‍♂️ NGINX Wizard

A one-command wizard to auto-configure **NGINX** with **SSL (Let's Encrypt)**, **WebSocket support**, and **reverse proxy** for your Django or Docker-based backend.

---

## 🚀 Features

- ✅ Auto-installs Nginx & Certbot (if not already)
- 🔐 Sets up HTTPS with Let's Encrypt
- 🌐 Asks for domain name
- 🔄 Supports custom proxy pass (e.g. `http://127.0.0.1:8000`)
- 🔌 Optional WebSocket support
- 🗂️ Serves static & media files from `/var/www/static` and `/var/www/media`

---

## 🧪 Quick Start

Run the wizard directly from your server:

```bash
bash <(curl -s https://raw.githubusercontent.com/nimiology/nginx-wizard/main/setup-nginx-ssl-ws-proxy.sh)
```

It will ask:

1. Your domain name (`example.com`)
2. Whether to enable WebSocket support
3. The backend address to proxy to (default: `http://127.0.0.1:8000`)

---

## 🛠️ Manual Installation

```bash
git clone https://github.com/nimiology/nginx-wizard.git
cd nginx-wizard
chmod +x setup-nginx-ssl-ws-proxy.sh
./setup-nginx-ssl-ws-proxy.sh
```

---

## 📁 Directory Structure

```bash
nginx-wizard/
├── setup-nginx-ssl-ws-proxy.sh  # The main interactive script
└── README.md
```

---

## 📎 Requirements

- A Debian-based system (e.g. Ubuntu)
- A valid domain pointing to your server's public IP
- Port 80 and 443 open on your firewall

---

## 🧩 What It Does

- Creates an Nginx config file at `/etc/nginx/sites-available/YOUR_DOMAIN`
- Enables it via symlink to `/etc/nginx/sites-enabled`
- Reloads Nginx
- Issues an SSL certificate using Certbot
- Sets up auto-renew via `certbot` (default on most systems)

---

## 🔒 Example Generated Config

```nginx
server {
    listen 80;
    server_name example.com www.example.com;

    location /static/ {
        alias /var/www/static/;
        expires 30d;
    }

    location /media/ {
        alias /var/www/media/;
        expires 30d;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        ...
    }
}
```

---

## 🧠 Why Use This?

Because manually configuring Nginx, Certbot, static/media paths, and WebSocket headers gets old fast. This script does it all for you — interactively and reliably.

---

## 🧊 License

MIT — use it freely and contribute if you like.

---

## ✨ Maintainer

Made with 🧠 by [@nimiology](https://github.com/nimiology)
