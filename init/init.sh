#!/bin/bash
# ==============================================
# B@tHome - Script d'initialisation des VMs
# DOIT etre lance en ROOT
# Usage: bash init.sh <USERNAME> <HOSTNAME>
# ==============================================

# Forcer /usr/sbin dans le PATH des le debut
# Necessaire sur Debian minimal ou ces commandes sont absentes du PATH par defaut
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
apt-get install -y curl sudo wget git ufw fail2ban net-tools htop nano

# 2. Configurer sudo pour l'utilisateur
echo "[2/6] Configuration de l'utilisateur $USERNAME..."
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# 3. Docker
echo "[3/6] Installation de Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USERNAME
systemctl enable docker
systemctl start docker

# 4. Firewall UFW
echo "[4/6] Configuration UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable

# 5. fail2ban
echo "[5/6] Configuration fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# 6. Hostname + SSH
echo "[6/6] Hostname et SSH..."
hostnamectl set-hostname $HOSTNAME_VM
sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

echo ""
echo "============================================================"
echo "VM $HOSTNAME_VM prete !"
echo "  SSH : ssh $USERNAME@IP_VM"
echo "============================================================"
