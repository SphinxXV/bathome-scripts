#!/bin/bash
# B@tHome — VM Victor (10.10.20.115) — Plex — User: medops
# Usage: bash victor.sh <plex_claim_token>
set -e
PLEX_CLAIM=${1:-""}
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) medops victor
echo "==> Installation Plex..."
mkdir -p /home/medops/docker/victor /media && cd /home/medops/docker/victor
printf "services:\n  plex:\n    container_name: plex\n    image: plexinc/pms-docker:latest\n    restart: unless-stopped\n    network_mode: host\n    environment:\n      - TZ=Europe/Paris\n      - PLEX_CLAIM=${PLEX_CLAIM}\n    volumes:\n      - ./plex-config:/config\n      - ./plex-transcode:/transcode\n      - /media:/data\n" > docker-compose.yml
chown -R medops:medops /home/medops/docker
docker compose up -d
echo ""
echo "============================================================"
echo " Victor installe !"
echo " Plex : http://10.10.20.115:32400/web"
echo " Node Exporter : http://10.10.20.115:9100/metrics"
echo " Medias dans /media"
echo "============================================================"