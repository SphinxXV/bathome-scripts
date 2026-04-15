#!/bin/bash
# ==============================================
# B@tHome - VM Cipher (Pi-hole DNS)
# Utilisateur: sysops
# Hostname: cipher
# ==============================================

SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"

echo "B@tHome - Initialisation de Cipher (Pi-hole DNS)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh sysops cipher
rm /tmp/init.sh

echo ""
echo "Cipher pret ! Prochaine etape : installer Pi-hole via Docker"
echo "  cd /home/sysops && sudo docker compose up -d"
