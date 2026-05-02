#!/bin/bash
# ==============================================
# B@tHome - VM Floyd (IA Locale)
# Utilisateur: aiops / Hostname: floyd
# Services: Ollama + Open WebUI + LLaVA Vision
# RAM: 8 Go minimum / Disque: 50 Go
# NOTE: Ollama tourne en CPU-only sur VM Debian
# sous VMware Fusion (pas d'acces GPU Apple M2)
# LANCER EN ROOT : su - puis bash floyd.sh
# ==============================================

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

INIT_URL="https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh"

echo "========================================"
echo " B@tHome - Floyd (IA Locale)"
echo "========================================"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR: Ce script doit etre lance en root"
    echo "Faire d'abord : su -"
    exit 1
fi

# Installer curl en PREMIER
echo "Installation de curl..."
apt-get update -y
apt-get install -y curl

# Init commun
curl -fsSL $INIT_URL -o /tmp/init.sh && bash /tmp/init.sh aiops floyd
rm -f /tmp/init.sh

mkdir -p /home/aiops/docker/floyd
cd /home/aiops/docker/floyd

# Installer Ollama
echo "Installation d'Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# CRITIQUE: Configurer Ollama pour ecouter sur toutes les interfaces
# Sans ca, Home Assistant ne peut pas atteindre l'API Ollama
mkdir -p /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/override.conf << 'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF

systemctl daemon-reload
systemctl enable ollama
systemctl start ollama

echo "Attente du demarrage d'Ollama (20 secondes)..."
sleep 20

# Telecharger les modeles
echo "Telechargement llama3.2:3b..."
ollama pull llama3.2:3b
echo "Telechargement llava:7b..."
ollama pull llava:7b

# Docker Compose pour Open WebUI
cat > docker-compose.yml << 'EOF'
services:
  open-webui:
    container_name: open-webui
    image: ghcr.io/open-webui/open-webui:main
    restart: unless-stopped
    ports:
      - "3002:8080"
    volumes:
      - ./open-webui-data:/app/backend/data
    environment:
      OLLAMA_BASE_URL: "http://host-gateway:11434"
      WEBUI_SECRET_KEY: "CHANGER_CETTE_CLE_SECRETE"
      WEBUI_NAME: "B@tHome AI"
      DEFAULT_MODELS: "llama3.2:3b"
    extra_hosts:
      - "host-gateway:host-gateway"
EOF

/usr/sbin/ufw allow 3002/tcp
/usr/sbin/ufw allow 11434/tcp
/usr/sbin/ufw reload

docker compose up -d

echo ""
echo "========================================"
echo " Floyd (IA Locale) installe !"
echo ""
echo " Open WebUI : http://$(hostname -I | awk '{print $1}'):3002"
echo " Ollama API : http://$(hostname -I | awk '{print $1}'):11434"
echo ""
echo " Modeles : llama3.2:3b + llava:7b"
echo ""
echo " Integration Home Assistant :"
echo "   Settings > Devices > Add > Ollama"
echo "   URL: http://IP_FLOYD:11434"
echo "========================================"
