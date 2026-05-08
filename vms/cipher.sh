#!/bin/bash
# B@tHome — VM Cipher (10.10.20.111) — Pi-hole DNS — User: sysops
set -e
bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh) sysops cipher
echo "==> Installation Pi-hole..."
ufw allow 53/tcp comment 'Pi-hole DNS'
ufw allow 53/udp comment 'Pi-hole DNS'
ufw allow 80/tcp comment 'Pi-hole Web'
ufw reload
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended
echo ""
echo "============================================================"
echo " Cipher installe !"
echo " Pi-hole : http://10.10.20.111/admin"
echo " Node Exporter : http://10.10.20.111:9100/metrics"
echo "============================================================"