#!/bin/bash
# ==============================================
# B@tHome - Installer Node Exporter sur une VM existante
# Usage: curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/node_exporter.sh | bash
# Port: 9100
# ==============================================

NE_VERSION="1.8.1"
ARCH="arm64"

echo "[Node Exporter] Installation v${NE_VERSION}..."

# Detecter l'architecture
if [ "$(uname -m)" = "x86_64" ]; then
    ARCH="amd64"
    elif [ "$(uname -m)" = "aarch64" ]; then
        ARCH="arm64"
        fi

        echo "[Node Exporter] Architecture: $ARCH"

        # Telecharger et installer
        wget -q https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/node_exporter-${NE_VERSION}.linux-${ARCH}.tar.gz -O /tmp/node_exporter.tar.gz
        tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
        cp /tmp/node_exporter-${NE_VERSION}.linux-${ARCH}/node_exporter /usr/local/bin/
        chmod +x /usr/local/bin/node_exporter
        rm -rf /tmp/node_exporter*

        # Service systemd
        cat > /etc/systemd/system/node_exporter.service << 'EOF'
Add node_exporter.sh - installation standalone sur VMs existantes        Description=Node Exporter - Metriques systeme pour Prometheus/Grafana
        After=network.target

        [Service]
        User=root
        ExecStart=/usr/local/bin/node_exporter
        Restart=always
        RestartSec=3

        [Install]
        WantedBy=multi-user.target
        EOF

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
                echo "[Node Exporter] Metriques disponibles sur : http://$(hostname -I | awk '{print $1}'):9100/metrics"
                
