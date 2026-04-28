#!/bin/bash
# ==============================================
# B@tHome - VM Bruce (IA locale)
# Utilisateur: aiops
# Hostname: bruce
# Services: Ollama + Open WebUI + LLaVA Vision
# RAM recommandee: 8 Go minimum
# ==============================================

SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh"

echo "B@tHome - Initialisation de Bruce (IA locale)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh aiops bruce
rm /tmp/init.sh

echo ""
echo "============================================================"
echo "Installation de Ollama + Open WebUI..."
echo "============================================================"

# Creer le dossier docker
mkdir -p /home/aiops/docker/bruce
cd /home/aiops/docker/bruce

# Installer Ollama directement sur la VM (plus performant que Docker)
curl -fsSL https://ollama.com/install.sh | sh
systemctl enable ollama
systemctl start ollama

# Attendre le demarrage d'Ollama
sleep 5

# Telecharger les modeles IA
echo "Telechargement des modeles IA (peut prendre plusieurs minutes)..."
# Llama 3.2 - modele texte general (3B = leger et rapide)
ollama pull llama3.2:3b
# LLaVA - modele vision pour analyser les cameras
ollama pull llava:7b

# Creer le docker-compose.yml pour Open WebUI
cat > docker-compose.yml << 'EOF'
services:
  # Open WebUI - Interface web pour Ollama
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
      # Connexion Home Assistant
      # OPENAI_API_BASE_URL: "http://IP_HOME_ASSISTANT:8123/api/ollama"
      # OPENAI_API_KEY: "TON_TOKEN_HOME_ASSISTANT"
    extra_hosts:
      - "host-gateway:host-gateway"
EOF

# Ouvrir les ports UFW
sudo ufw allow 3002/tcp   # Open WebUI
sudo ufw allow 11434/tcp  # Ollama API
sudo ufw reload

# Lancer Open WebUI
sudo docker compose up -d

echo ""
echo "============================================================"
echo "Bruce (IA locale) installe avec succes !"
echo ""
echo "  Open WebUI  : http://$(hostname -I | awk '{print $1}'):3002"
echo "  Ollama API  : http://$(hostname -I | awk '{print $1}'):11434"
echo ""
echo "Modeles installes :"
echo "  - llama3.2:3b  -> taches texte generales"
echo "  - llava:7b     -> analyse des cameras (vision)"
echo ""
echo "Pour ajouter d'autres modeles :"
echo "  ollama pull mistral"
echo "  ollama pull llama3.2:1b  (ultra leger)"
echo ""
echo "IMPORTANT : Configurer Home Assistant"
echo "  1. Installer l'addon 'Ollama' dans HA"
echo "  2. URL Ollama : http://IP_BRUCE:11434"
echo "  3. Pour les cameras : utiliser le modele llava:7b"
echo "============================================================"
