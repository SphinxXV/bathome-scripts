#!/bin/bash
# B@tHome — VM Ras (10.10.20.110) — Vaultwarden — User: vltops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) vltops ras
echo "==> Installation Vaultwarden..."
mkdir -p /home/vltops/docker/ras && cd /home/vltops/docker/ras
printf 'services:\n  vaultwarden:\n    container_name: vaultwarden\n    image: vaultwarden/server:latest\n    restart: unless-stopped\n    ports:\n      - "8080:80"\n    volumes:\n      - ./data:/data\n    environment:\n      - SIGNUPS_ALLOWED=false\n      - WEBSOCKET_ENABLED=true\n      - DOMAIN=https://zola.waynenet.eu\n' > docker-compose.yml
chown -R vltops:vltops /home/vltops/docker
ufw allow 8080/tcp comment 'Vaultwarden'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Ras installe !"
echo " Vaultwarden : http://10.10.20.110:8080"
echo " Node Exporter : http://10.10.20.110:9100/metrics"
echo "============================================================"