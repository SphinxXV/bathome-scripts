#!/bin/bash
# B@tHome — VM Shiva (10.10.20.116) — Zigbee2MQTT — User: zigops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) zigops shiva
echo "==> Installation Zigbee2MQTT..."
mkdir -p /home/zigops/docker/shiva && cd /home/zigops/docker/shiva
printf 'services:\n  zigbee2mqtt:\n    container_name: zigbee2mqtt\n    image: koenkk/zigbee2mqtt:latest\n    restart: unless-stopped\n    ports:\n      - "8099:8080"\n    volumes:\n      - ./data:/app/data\n      - /run/udev:/run/udev:ro\n    environment:\n      - TZ=Europe/Paris\n' > docker-compose.yml
chown -R zigops:zigops /home/zigops/docker
ufw allow 8099/tcp comment 'Zigbee2MQTT'
ufw allow 1883/tcp comment 'MQTT'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Shiva installe !"
echo " Zigbee2MQTT : http://10.10.20.116:8099"
echo " Node Exporter : http://10.10.20.116:9100/metrics"
echo " Configurer adaptateur Zigbee dans data/configuration.yaml"
echo "============================================================"