#!/bin/bash
# ==============================================
# B@tHome - VM Floyd (IA Locale)
# Utilisateur: aiops / Hostname: floyd
# Services: Ollama + Open WebUI + LLaVA Vision
# RAM: 8 Go minimum / Disque: 50 Go
# LANCER EN ROOT depuis la console VMware
# ou en SSH apres avoir fait : su -
# ==============================================

# CORRECTION CRITIQUE : forcer le PATH complet
# Necesaire sur Debian minimal sinon usermod etc introuvable
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

INIT_URL="https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh"

echo "========================================"
echo " B@tHome - Floyd (IA Locale)"
echo "========================================"

# Verifier qu'on est bien root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR: Ce script doit etre lance en root"
    echo "Faire d'abord : su -"
    exit 1
fi

# Init commun (installe Docker, UFW, sudo, fail2ban...)
curl -fsSL $INIT_URL -o /tmp/init.sh && bash /tmp/init.sh aiops floyd
rm -f /tmp/init.sh

# Creer le dossier docker dans le home de aiops
mkdir -p /home/aiops/docker/floyd
cd /home/aiops/docker/floyd

# Installer Ollama directement sur la VM (plus performant que Docker sur ARM)
echo "Installation d'Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
systemctl enable ollama
systemctl start ollama

# Attendre le demarrage d'Ollama
echo "Attente du demarrage d'Ollama (20 secondes)..."
sleep 20

# Telecharger les modeles IA
echo "Telechargement llama3.2:3b (modele texte leger)..."
ollama pull llama3.2:3b

echo "Telechargement llava:7b (modele vision cameras)..."
ollama pull llava:7b

# Creer le docker-compose.yml pour Open WebUI
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

# Ouvrir les ports UFW
/usr/sbin/ufw allow 3002/tcp   # Open WebUI
/usr/sbin/ufw allow 11434/tcp  # Ollama API (pour Home Assistant)
/usr/sbin/ufw reload

# Lancer Open WebUI
docker compose up -d

echo ""
echo "========================================"
echo " Floyd (IA Locale) installe !"
echo ""
echo " Open WebUI : http://$(hostname -I | awk '{print $1}'):3002"
echo " Ollama API : http://$(hostname -I | awk '{print $1}'):11434"
echo ""
echo " Modeles disponibles :"
echo "   llama3.2:3b  -> taches texte (rapide)"
echo "   llava:7b     -> analyse cameras"
echo ""
echo " Intégration Home Assistant :"
echo "   Settings > Devices & Services > Add > Ollama"
echo "   URL: http://IP_FLOYD:11434"
echo "========================================"
