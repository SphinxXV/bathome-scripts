#!/bin/bash
# ==============================================
# B@tHome - VM Slade (Nginx Proxy Manager)
# Utilisateur: proxops
# Hostname: slade
# ==============================================

SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"

echo "B@tHome - Initialisation de Slade (Nginx Proxy Manager)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh proxops slade
rm /tmp/init.sh

echo ""
echo "Slade pret ! Prochaine etape : installer Nginx Proxy Manager via Docker"
echo "  Domaines: waynenet.eu + baxo.me"
