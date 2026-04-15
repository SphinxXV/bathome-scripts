#!/bin/bash
# ==============================================
# B@tHome - VM Waller (Monitoring)
# Utilisateur: monops
# Hostname: waller
# ==============================================
SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/batome-scripts/main/init/init.sh"
echo "B@tHome - Initialisation de Waller (Monitoring)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh monops waller
rm /tmp/init.sh
echo ""
echo "Waller pret ! Prochaine etape : installer Grafana + InfluxDB + Uptime Kuma via Docker"
echo "  URL: grafana.waynenet.eu"
