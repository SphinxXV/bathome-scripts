#!/bin/bash
# B@tHome â VM Waller (10.10.20.112) â Monitoring stack â User: monops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) monops waller
echo "==> Installation stack monitoring..."
mkdir -p /home/monops/docker/waller/prometheus-config && cd /home/monops/docker/waller
cat > prometheus-config/prometheus.yml << 'PROM'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets:
          - '10.10.20.111:9100'
          - '10.10.20.113:9100'
          - '10.10.20.110:9100'
          - '10.10.20.117:9100'
          - '10.10.20.114:9100'
          - '10.10.20.112:9100'
          - '10.10.20.116:9100'
          - '10.10.20.115:9100'
          - '10.10.20.118:9100'
PROM
printf 'services:\n\n  grafana:\n    container_name: grafana\n    image: grafana/grafana:latest\n    restart: unless-stopped\n    ports:\n      - "3000:3000"\n    volumes:\n      - ./grafana-data:/var/lib/grafana\n    environment:\n      - GF_SECURITY_ADMIN_PASSWORD=BatHome2026!\n\n  prometheus:\n    container_name: prometheus\n    image: prom/prometheus:latest\n    restart: unless-stopped\n    network_mode: host\n    volumes:\n      - ./prometheus-config:/etc/prometheus\n      - ./prometheus-data:/prometheus\n    command:\n      - "--config.file=/etc/prometheus/prometheus.yml"\n      - "--storage.tsdb.path=/prometheus"\n\n  uptime-kuma:\n    container_name: uptime-kuma\n    image: louislam/uptime-kuma:latest\n    restart: unless-stopped\n    ports:\n      - "3001:3001"\n    volumes:\n      - ./uptime-data:/app/data\n\n  termix:\n    container_name: termix\n    image: ghcr.io/lukegus/termix:latest\n    restart: unless-stopped\n    ports:\n      - "8888:8080"\n    volumes:\n      - ./termix-data:/data\n\n  nut-upsd:\n    container_name: nut_upsd\n    image: instantlinux/nut-upsd:latest\n    restart: unless-stopped\n    ports:\n      - "3493:3493"\n    environment:\n      - UPS_NAME=bathome\n      - API_USER=upsmonitor\n      - API_PASSWORD=BatHome2026!\n    volumes:\n      - ./nut-data:/etc/nut\n    devices:\n      - /dev/bus/usb:/dev/bus/usb\n' > docker-compose.yml
mkdir -p grafana-data prometheus-data uptime-data termix-data nut-data
chown -R 472:472 grafana-data
chown -R 65534:65534 prometheus-data
chown -R monops:monops /home/monops/docker
ufw allow 3000/tcp comment 'Grafana'
ufw allow 3001/tcp comment 'Uptime Kuma'
ufw allow 8888/tcp comment 'Termix'
ufw allow 3493/tcp comment 'NUT'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Waller installe !"
echo " Grafana      : http://10.10.20.112:3000 (admin/BatHome2026!)"
echo " Uptime Kuma  : http://10.10.20.112:3001"
echo " Termix       : http://10.10.20.112:8888"
echo " Etapes : datasource Prometheus, dashboard ID 1860, proxies NPM"
echo "============================================================"