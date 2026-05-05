#!/bin/bash
# ==============================================
# B@tHome - Installer Node Exporter sur une VM existante
# Usage: curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/node_exporter.sh -o /tmp/ne.sh && sudo bash /tmp/ne.sh
# Port: 9100
# ==============================================

NE_VERSION="1.8.1"

# Detecter l'architecture
ARCH="arm64"
if [ "$(uname -m)" = "x86_64" ]; then
    ARCH="amd64"
    elif [ "$(uname -m)" = "aarch64" ]; then
        ARCH="arm64"
        fi

        echo "[Node Exporter] Installation v${NE_VERSION} (${ARCH})..."

        # Telecharger et installer le binaire
        wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/node_exporter-${NE_VERSION}.linux-${ARCH}.tar.gz" -O /tmp/node_exporter.tar.gz
        tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
        cp "/tmp/node_exporter-${NE_VERSION}.linux-${ARCH}/node_exporter" /usr/local/bin/
        chmod +x /usr/local/bin/node_exporter
        rm -rf /tmp/node_exporter*

        # Creer le service systemd (sans heredoc)
        SERVICE_FILE="/etc/systemd/system/node_exporter.service"
Fix node_exporter.sh - remove heredoc, use echo instead        echo "Description=Node Exporter - Metriques systeme pour Prometheus/Grafana" >> $SERVICE_FILE
        echo "After=network.target" >> $SERVICE_FILE
        echo "" >> $SERVICE_FILE
        echo "[Service]" >> $SERVICE_FILE
        echo "User=root" >> $SERVICE_FILE
        echo "ExecStart=/usr/local/bin/node_exporter" >> $SERVICE_FILE
        echo "Restart=always" >> $SERVICE_FILE
        echo "RestartSec=3" >> $SERVICE_FILE
        echo "" >> $SERVICE_FILE
        echo "[Install]" >> $SERVICE_FILE
        echo "WantedBy=multi-user.target" >> $SERVICE_FILE

        systemctl daemon-reload
        systemctl enable node_exporter
        systemctl start node_exporter

        # Ouvrir le port UFW si disponible
        if command -v ufw &>/dev/null; then
            ufw allow 9100/tcp
                ufw reload
                fi

                echo ""
                echo "[Node Exporter] Installe et demarre !"
                echo "[Node Exporter] Metriques : http://$(hostname -I | awk '{print $1}'):9100/metrics"
                systemctl status node_exporter --no-pager
                
