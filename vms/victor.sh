#!/bin/bash
# ==============================================
# B@tHome - VM Victor (Multimedia)
# Utilisateur: medops
# Hostname: victor
# ==============================================
SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"
echo "B@tHome - Initialisation de Victor (Multimedia)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh medops victor
rm /tmp/init.sh
echo ""
echo "Victor pret ! Prochaine etape : installer Plex + Sonarr + Radarr via Docker"
echo "  URLs: plex.baxo.me | download.baxo.me"
echo "  Seedbox: Seedit4.me"
