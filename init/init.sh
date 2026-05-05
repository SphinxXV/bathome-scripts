#!/bin/bash
# ==============================================
# B@tHome - Script d'initialisation des VMs
# DOIT etre lance en ROOT
# Usage: bash init.sh <USERNAME> <HOSTNAME>
# Installe: outils de base + Docker + Node Exporter
# ==============================================

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USERNAME=$1
HOSTNAME_VM=$2

if [ -z "$USERNAME" ] || [ -z "$HOSTNAME_VM" ]; then
    echo "Usage: bash init.sh <USERNAME> <HOSTNAME>"
        exit 1
        fi

        echo "B@tHome - Initialisation de $HOSTNAME_VM"
        echo "============================================================"

        # 1. Mise a jour + installation de tout en une seule commande apt
        echo "[1/6] Mise a jour et installation des outils..."
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y \
            curl wget git vim htop \
                ca-certificates gnupg lsb-release \
                    ufw sudo net-tools \
                        apt-transport-https software-properties-common

                        # 2. Configurer sudo pour l'utilisateur
                        echo "[2/6] Creation utilisateur $USERNAME..."
                        if ! id "$USERNAME" &>/dev/null; then
                            useradd -m -s /bin/bash "$USERNAME"
                                echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME
                                    chmod 440 /etc/sudoers.d/$USERNAME
                                    fi

                                    # 3. Configurer hostname
                                    echo "[3/6] Configuration hostname $HOSTNAME_VM..."
                                    hostnamectl set-hostname "$HOSTNAME_VM"
                                    echo "127.0.1.1 $HOSTNAME_VM" >> /etc/hosts

                                    # 4. Installer Docker
                                    echo "[4/6] Installation Docker..."
                                    if ! command -v docker &>/dev/null; then
                                        curl -fsSL https://get.docker.com | bash
                                            usermod -aG docker "$USERNAME"
                                            fi

                                            # 5. Configurer UFW
                                            echo "[5/6] Configuration pare-feu UFW..."
                                            ufw --force enable
                                            ufw allow OpenSSH
                                            ufw allow 9100/tcp  # Node Exporter

                                            # 6. Installer Node Exporter (metriques CPU/RAM/Disk pour Grafana)
                                            echo "[6/6] Installation Node Exporter (metriques Grafana)..."
                                            NE_VERSION="1.8.1"
                                            wget -q https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/node_exporter-${NE_VERSION}.linux-arm64.tar.gz -O /tmp/node_exporter.tar.gz
                                            tar -xzf /tmp/node_exporter.tar.gz -C /tmp/
                                            cp /tmp/node_exporter-${NE_VERSION}.linux-arm64/node_exporter /usr/local/bin/
                                            chmod +x /usr/local/bin/node_exporter
                                            rm -rf /tmp/node_exporter*

                                            # Creer service systemd pour Node Exporter
                                            cat > /etc/systemd/system/node_exporter.service << 'EOF'
                                            [Unit]
                                            Description=Node Exporter - Metriques systeme pour Prometheus/Grafana
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

                                            echo ""
                                            echo "============================================================"
                                            echo " $HOSTNAME_VM initialise avec succes !"
                                            echo ""
                                            echo " Utilisateur : $USERNAME"
                                            echo " Docker      : $(docker --version)"
                                            echo " Node Exporter : http://$(hostname -I | awk '{print $1}'):9100/metrics"
                                            echo "============================================================"
                                            
