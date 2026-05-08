#!/bin/bash
# =============================================================
# B@tHome — node_exporter.sh
# Installation Node Exporter v1.8.1 ARM64
# =============================================================

set -e

NE_VERSION="1.8.1"
NE_ARCH="arm64"
NE_URL="https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/node_exporter-${NE_VERSION}.linux-${NE_ARCH}.tar.gz"

echo "==> Installation Node Exporter v${NE_VERSION}..."

wget -q "$NE_URL" -O /tmp/ne.tar.gz
tar -xzf /tmp/ne.tar.gz -C /tmp/
cp /tmp/node_exporter-${NE_VERSION}.linux-${NE_ARCH}/node_exporter /usr/local/bin/
chmod +x /usr/local/bin/node_exporter
rm -rf /tmp/ne.tar.gz /tmp/node_exporter-${NE_VERSION}.linux-${NE_ARCH}

printf '[Unit]\nDescription=Node Exporter\nAfter=network.target\n\n[Service]\nUser=root\nExecStart=/usr/local/bin/node_exporter\nRestart=always\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/node_exporter.service

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

ufw allow 9100/tcp comment 'Node Exporter'
ufw reload

echo "==> Node Exporter installe et actif sur le port 9100"
