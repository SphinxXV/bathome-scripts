#!/bin/bash
# B@tHome — VM Matches (10.10.20.114) — Homarr — User: svcops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) svcops matches
echo "==> Installation Homarr..."
mkdir -p /home/svcops/docker/matches && cd /home/svcops/docker/matches
printf 'services:\n  homarr:\n    container_name: homarr\n    image: ghcr.io/ajnart/homarr:latest\n    restart: unless-stopped\n    ports:\n      - "7575:7575"\n    volumes:\n      - ./homarr-config:/app/data/configs\n      - ./homarr-icons:/app/public/icons\n      - ./homarr-data:/data\n' > docker-compose.yml
chown -R svcops:svcops /home/svcops/docker
ufw allow 7575/tcp comment 'Homarr'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Matches installe !"
echo " Homarr : http://10.10.20.114:7575"
echo " Node Exporter : http://10.10.20.114:9100/metrics"
echo "============================================================"