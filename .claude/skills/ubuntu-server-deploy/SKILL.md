---
name: ubuntu-server-deploy
description: Deploy web applications, APIs, and services to Ubuntu servers via SSH. Use when user asks to deploy to ubuntu, setup a VPS, configure nginx/systemd/caddy, setup SSL with Let's Encrypt / certbot, configure UFW firewall, harden SSH, set up unattended-upgrades, deploy Node.js/Python/Go/Rust apps to a Linux server, install PostgreSQL/MySQL/Redis, configure fail2ban, create systemd services, setup reverse proxy, or any Ubuntu 22.04/24.04 server administration and production deployment task.
---

# Ubuntu Server Deploy

Production-grade deployment playbook for Ubuntu 22.04 LTS and 24.04 LTS servers.

## Quick reference

### 1. Initial server hardening (run once, new VPS)

```bash
# Update + unattended security upgrades
sudo apt update && sudo apt upgrade -y
sudo apt install -y unattended-upgrades apt-listchanges
sudo dpkg-reconfigure -plow unattended-upgrades

# Create non-root sudo user
sudo adduser deploy
sudo usermod -aG sudo deploy
sudo mkdir -p /home/deploy/.ssh
sudo cp ~/.ssh/authorized_keys /home/deploy/.ssh/
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh && sudo chmod 600 /home/deploy/.ssh/authorized_keys

# SSH hardening (/etc/ssh/sshd_config)
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
sudo systemctl restart ssh

# UFW firewall — deny incoming, allow ssh/http/https
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow http
sudo ufw allow https
sudo ufw enable

# fail2ban for brute-force protection
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
```

### 2. Install a runtime

```bash
# Node.js LTS (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Python 3 + venv
sudo apt install -y python3 python3-pip python3-venv

# Go
sudo apt install -y golang-go

# Rust (as deploy user)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker deploy

# PostgreSQL 16
sudo apt install -y postgresql postgresql-contrib
sudo -u postgres psql -c "CREATE USER myapp WITH PASSWORD 'xxx';"
sudo -u postgres psql -c "CREATE DATABASE myapp_prod OWNER myapp;"
```

### 3. Nginx reverse proxy + HTTPS

```bash
sudo apt install -y nginx certbot python3-certbot-nginx

# Minimal site config: /etc/nginx/sites-available/myapp
# server {
#   listen 80;
#   server_name example.com;
#   location / {
#     proxy_pass http://127.0.0.1:3000;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header X-Forwarded-Proto $scheme;
#     proxy_http_version 1.1;
#     proxy_set_header Upgrade $http_upgrade;
#     proxy_set_header Connection "upgrade";
#   }
# }

sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Let's Encrypt — auto-renewal via systemd timer
sudo certbot --nginx -d example.com -d www.example.com --non-interactive --agree-tos -m admin@example.com
# Renewal is already scheduled via /etc/systemd/system/timers.target.wants/certbot.timer
```

**Alternative: Caddy** (zero-config HTTPS, simpler than nginx):

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy

# /etc/caddy/Caddyfile (HTTPS automatic):
# example.com {
#   reverse_proxy localhost:3000
# }
sudo systemctl reload caddy
```

### 4. systemd service (for persistent apps)

`/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=My App
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=simple
User=deploy
Group=deploy
WorkingDirectory=/home/deploy/myapp
Environment=NODE_ENV=production
EnvironmentFile=/home/deploy/myapp/.env
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

# Hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/deploy/myapp/logs /home/deploy/myapp/uploads

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now myapp
sudo systemctl status myapp
sudo journalctl -u myapp -f  # live logs
```

### 5. Zero-downtime deploys (Node/Python/Go)

**Rsync + systemd restart** (simple):
```bash
rsync -avz --delete --exclude=node_modules ./ deploy@server:/home/deploy/myapp/
ssh deploy@server 'cd myapp && npm ci --production && sudo systemctl restart myapp'
```

**Git pull + build** (versioned):
```bash
ssh deploy@server 'cd myapp && git fetch && git reset --hard origin/main && npm ci && npm run build && sudo systemctl restart myapp'
```

**Blue/Green with symlinks** (zero downtime):
```bash
# Deploy to /home/deploy/releases/YYYYMMDD-HHMMSS
# Symlink /home/deploy/current -> new release
# systemctl restart myapp
# Keep last 5 releases for rollback
```

### 6. Monitoring & logs

```bash
# Journal (systemd)
journalctl -u myapp --since "1 hour ago"
journalctl -u myapp -f  # tail -f

# Disk / RAM / CPU
df -h && free -h && top -bn1 | head -20

# nginx access + error logs
sudo tail -f /var/log/nginx/access.log /var/log/nginx/error.log

# Optional: node_exporter for Prometheus
# sudo apt install prometheus-node-exporter
```

### 7. Backups

```bash
# PostgreSQL daily dump + rotate
sudo -u postgres pg_dump myapp_prod | gzip > /backups/myapp-$(date +%F).sql.gz
find /backups -name 'myapp-*.sql.gz' -mtime +14 -delete

# rclone to S3/Backblaze (after config):
rclone sync /backups remote:bucket/backups --progress
```

## Decision tree

| Situation | Choose |
|---|---|
| Simple static site or API, want zero config HTTPS | **Caddy** |
| Need fine control, multiple backends, custom caching | **nginx + certbot** |
| Node.js app, single instance | **systemd** service |
| Multi-instance Node | **pm2** (`npm i -g pm2; pm2 startup systemd`) |
| Multiple apps on one server | **Docker + Caddy** reverse proxy |
| Need rollback & versioning | **Blue/Green** with symlinks |
| High availability | **2+ servers + nginx upstream** or k8s |

## Common pitfalls

1. **Forgot to enable UFW before installing nginx** → public ssh stays open but new services are blocked. Always `ufw allow` the port after service install.
2. **Certbot fails with rate limit** → use `--staging` flag first to test, then real cert.
3. **systemd service fails silently** → always check `journalctl -u SERVICE` and `systemctl status SERVICE`.
4. **Postgres `peer` auth fails** → use `md5` or `scram-sha-256` in `/etc/postgresql/16/main/pg_hba.conf` and reload.
5. **nginx 502 Bad Gateway** → your app isn't listening on `127.0.0.1:PORT`, or firewall/apparmor is blocking it. Check `ss -tlnp`.
6. **Out of inodes from logs** → configure `logrotate` for app logs, use `journalctl --vacuum-size=500M`.
7. **fail2ban banning yourself** → add your IP to `ignoreip` in `/etc/fail2ban/jail.local`.

## Related skills

- `devops-engineer` — Dockerfiles, CI/CD pipelines
- `kubernetes-specialist` — if you outgrow single-server
- `terraform-engineer` — provision the server itself via IaC
- `postgres-pro` — database tuning after install
- `monitoring-expert` — Prometheus + Grafana stack
- `security-reviewer` — post-deploy security audit
