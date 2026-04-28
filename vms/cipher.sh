#!/bin/bash
# ==============================================
# B@tHome - VM Cipher (Pi-hole DNS)
# Utilisateur: sysops
# Hostname: cipher
# ==============================================

SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh"

echo "B@tHome - Initialisation de Cipher (Pi-hole DNS)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh sysops cipher
rm /tmp/init.sh

echo ""
echo "============================================================"
echo "Installation de Pi-hole via Docker..."
echo "============================================================"

# Creer le dossier docker
mkdir -p /home/sysops/docker/pihole
cd /home/sysops/docker/pihole

# Creer le docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    restart: unless-stopped
    network_mode: host
    environment:
      TZ: "Europe/Paris"
      WEBPASSWORD: "CHANGER_CE_MOT_DE_PASSE"
      PIHOLE_DNS_: "1.1.1.1;8.8.8.8"
      DNSMASQ_LISTENING: "all"
    volumes:
      - ./etc-pihole:/etc/pihole
      - ./etc-dnsmasq.d:/etc/dnsmasq.d
    cap_add:
      - NET_ADMIN
EOF

# Ouvrir les ports UFW necessaires
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 80/tcp
sudo ufw reload

# Lancer Pi-hole
sudo docker compose up -d

# Attendre que Pi-hole demarre
echo "Attente du demarrage de Pi-hole..."
sleep 10

# IMPORTANT : Configurer Pi-hole pour accepter les requetes de tous les VLANs
# Sans cette commande, Pi-hole ignore les requetes des reseaux non-locaux
sudo docker exec pihole pihole-FTL --config dns.listeningMode all
sudo docker compose restart

echo ""
echo "============================================================"
echo "Cipher + Pi-hole installes avec succes !"
echo "  Interface web : http://$(hostname -I | awk '{print $1}')/admin"
echo "  DNS Pi-hole   : $(hostname -I | awk '{print $1}') port 53"
echo ""
echo "IMPORTANT : Changer le mot de passe Pi-hole :"
echo "  sudo docker exec -it pihole pihole setpassword"
echo "============================================================"
