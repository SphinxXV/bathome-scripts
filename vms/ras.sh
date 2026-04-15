#!/bin/bash
# ==============================================
# B@tHome - VM Ra's (Vaultwarden)
# Utilisateur: vltops
# Hostname: ras
# ==============================================
SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"
echo "B@tHome - Initialisation de Ra s (Vaultwarden)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh vltops ras
rm /tmp/init.sh
echo ""
echo "Ra s pret ! Prochaine etape : installer Vaultwarden via Docker"
echo "  URL: vaultwarden.waynenet.eu"
