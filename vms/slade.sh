#!/bin/bash
# B@tHome — VM Slade (10.10.20.113) — Nginx Proxy Manager — User: proxops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) proxops slade
echo "==> Installation Nginx Proxy Manager..."
mkdir -p /home/proxops/docker/slade && cd /home/proxops/docker/slade
printf 'services:\n  npm:\n    container_name: nginx_proxy_manager\n    image: jc21/nginx-proxy-manager:latest\n    restart: unless-stopped\n    ports:\n      - "80:80"\n      - "443:443"\n      - "81:81"\n    volumes:\n      - ./data:/data\n      - ./letsencrypt:/etc/letsencrypt\n' > docker-compose.yml
chown -R proxops:proxops /home/proxops/docker
ufw allow 80/tcp comment 'NPM HTTP'
ufw allow 443/tcp comment 'NPM HTTPS'
ufw allow 81/tcp comment 'NPM Admin'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Slade installe !"
echo " NPM Admin : http://10.10.20.113:81"
echo " Login par defaut : admin@example.com / changeme"
echo " Node Exporter : http://10.10.20.113:9100/metrics"
echo "============================================================"