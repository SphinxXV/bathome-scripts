#!/bin/bash
# ==============================================
# B@tHome - VM Matches (Services + Dashboard)
# Utilisateur: svcops
# Hostname: matches
# ==============================================
SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"
echo "B@tHome - Initialisation de Matches (Services + Dashboard)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh svcops matches
rm /tmp/init.sh
echo ""
echo "Matches pret ! Prochaine etape : installer Portainer + Dashy + Termix + Ntfy via Docker"
echo "  URLs: baxo.me | portainer.baxo.me | termix.baxo.me"
