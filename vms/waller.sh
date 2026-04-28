#!/bin/bash
# ==============================================
# B@tHome - VM Waller (Monitoring)
# Utilisateur: monops
# Hostname: waller
# Services: Grafana + InfluxDB + Uptime Kuma + UniFi Log Insights
# ==============================================

SCRIPT_URL="https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/init.sh"

echo "B@tHome - Initialisation de Waller (Monitoring)"
curl -fsSL $SCRIPT_URL -o /tmp/init.sh
bash /tmp/init.sh monops waller
rm /tmp/init.sh

echo ""
echo "============================================================"
echo "Installation des services de monitoring..."
echo "============================================================"

# Creer les dossiers docker
mkdir -p /home/monops/docker/waller
cd /home/monops/docker/waller

# Creer le docker-compose.yml
cat > docker-compose.yml << 'EOF'
services:

  # InfluxDB - Base de donnees time-series
  influxdb:
    container_name: influxdb
    image: influxdb:2.7
    restart: unless-stopped
    ports:
      - "8086:8086"
    volumes:
      - ./influxdb-data:/var/lib/influxdb2
      - ./influxdb-config:/etc/influxdb2
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME: admin
      DOCKER_INFLUXDB_INIT_PASSWORD: CHANGER_CE_MOT_DE_PASSE
      DOCKER_INFLUXDB_INIT_ORG: bathome
      DOCKER_INFLUXDB_INIT_BUCKET: network

  # Grafana - Dashboard de monitoring
  grafana:
    container_name: grafana
    image: grafana/grafana:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./grafana-data:/var/lib/grafana
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: CHANGER_CE_MOT_DE_PASSE
      GF_SERVER_ROOT_URL: https://grafana.waynenet.eu
    depends_on:
      - influxdb

  # Uptime Kuma - Monitoring de disponibilite
  uptime-kuma:
    container_name: uptime-kuma
    image: louislam/uptime-kuma:latest
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./uptime-kuma-data:/app/data

  # UniFi Log Insights - Analyse des logs UniFi + MCP pour Claude
  # Source: https://github.com/jmasarweh/Unifi-Log-Insights
  # Acces: http://IP_WALLER:4000
  # MCP: connecte Claude a ton reseau UniFi pour diagnostics en langage naturel
  unifi-log-insights:
    container_name: unifi-log-insights
    image: ghcr.io/jmasarweh/unifi-log-insights:latest
    restart: unless-stopped
    ports:
      - "4000:4000"      # Interface web
      - "5514:5514/udp"  # Recepteur syslog UniFi
      - "8765:8765"      # MCP server pour Claude
    volumes:
      - ./uli-data:/app/data
    environment:
      TZ: "Europe/Paris"
      # Connexion au controleur UniFi (UDM-SE)
      UNIFI_HOST: "10.10.10.100"
      UNIFI_API_KEY: "METTRE_TA_CLE_API_UNIFI"
      # MaxMind GeoIP (compte gratuit sur maxmind.com)
      MAXMIND_ACCOUNT_ID: "METTRE_TON_ACCOUNT_ID"
      MAXMIND_LICENSE_KEY: "METTRE_TA_LICENSE_KEY"
EOF

# Ouvrir les ports UFW necessaires
sudo ufw allow 3000/tcp   # Grafana
sudo ufw allow 3001/tcp   # Uptime Kuma
sudo ufw allow 8086/tcp   # InfluxDB
sudo ufw allow 4000/tcp   # UniFi Log Insights
sudo ufw allow 5514/udp   # Syslog UniFi
sudo ufw allow 8765/tcp   # MCP server
sudo ufw reload

# Lancer tous les services
sudo docker compose up -d

echo ""
echo "============================================================"
echo "Waller installe avec succes !"
echo ""
echo "  Grafana        : http://$(hostname -I | awk '{print $1}'):3000"
echo "  Uptime Kuma    : http://$(hostname -I | awk '{print $1}'):3001"
echo "  InfluxDB       : http://$(hostname -I | awk '{print $1}'):8086"
echo "  UniFi Insights : http://$(hostname -I | awk '{print $1}'):4000"
echo "  MCP server     : http://$(hostname -I | awk '{print $1}'):8765"
echo ""
echo "IMPORTANT avant de lancer UniFi Log Insights :"
echo "  1. Cree une cle API UniFi : UniFi > Settings > Control Plane > API"
echo "  2. Cree un compte MaxMind (gratuit) : maxmind.com"
echo "  3. Configure Oracle (UDM-SE) pour envoyer les syslog vers IP_WALLER:5514"
echo "     UniFi > Settings > System > Remote Syslog"
echo "  4. Mets a jour le docker-compose.yml avec tes vraies cles"
echo "  5. Relance : sudo docker compose up -d"
echo "============================================================"
