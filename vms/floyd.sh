#!/bin/bash
# B@tHome — VM Floyd (10.10.20.117) — Ollama + OpenWebUI — User: aiops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) aiops floyd
echo "==> Installation Ollama + OpenWebUI..."
mkdir -p /home/aiops/docker/floyd && cd /home/aiops/docker/floyd
printf 'services:\n\n  ollama:\n    container_name: ollama\n    image: ollama/ollama:latest\n    restart: unless-stopped\n    ports:\n      - "11434:11434"\n    volumes:\n      - ./ollama-data:/root/.ollama\n\n  openwebui:\n    container_name: openwebui\n    image: ghcr.io/open-webui/open-webui:main\n    restart: unless-stopped\n    depends_on:\n      - ollama\n    ports:\n      - "3002:8080"\n    environment:\n      - OLLAMA_BASE_URL=http://ollama:11434\n    volumes:\n      - ./openwebui-data:/app/backend/data\n' > docker-compose.yml
chown -R aiops:aiops /home/aiops/docker
ufw allow 11434/tcp comment 'Ollama'
ufw allow 3002/tcp comment 'OpenWebUI'
ufw reload
docker compose up -d
echo ""
echo "============================================================"
echo " Floyd installe !"
echo " OpenWebUI : http://10.10.20.117:3002"
echo " Node Exporter : http://10.10.20.117:9100/metrics"
echo "============================================================"