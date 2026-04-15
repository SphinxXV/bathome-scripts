#!/bin/bash
# ==============================================
# B@tHome - Script d'initialisation des VMs
# Usage: bash init.sh <USERNAME> <HOSTNAME>
# Exemple: bash init.sh sysops cipher
# ==============================================

set -e

USERNAME=$1
HOSTNAME_VM=$2

if [ -z "$USERNAME" ] || [ -z "$HOSTNAME_VM" ]; then
    echo "Usage: bash init.sh <USERNAME> <HOSTNAME>"
    exit 1
fi

echo "B@tHome - Initialisation de $HOSTNAME_VM avec $USERNAME"
echo "============================================================"

# 1. Mise a jour systeme
echo "[1/8] Mise a jour du systeme..."
apt update && apt upgrade -y

# 2. Outils de base
echo "[2/8] Installation des outils de base..."
apt install -y curl wget git ufw fail2ban sudo net-tools htop nano

# 3. Creation de l'utilisateur
echo "[3/8] Creation de l'utilisateur $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "  -> Utilisateur $USERNAME existe deja"
else
    adduser --disabled-password --gecos "" $USERNAME
fi
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# 4. Docker
echo "[4/8] Installation de Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USERNAME
systemctl enable docker
systemctl start docker

# 5. Firewall UFW
echo "[5/8] Configuration du firewall UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

# 6. fail2ban
echo "[6/8] Configuration de fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# 7. Hostname
echo "[7/8] Configuration du hostname..."
hostnamectl set-hostname $HOSTNAME_VM

# 8. Securisation SSH
echo "[8/8] Securisation SSH..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo ""
echo "============================================================"
echo "VM $HOSTNAME_VM initialisee avec succes !"
echo "  Utilisateur : $USERNAME"
echo "  Root SSH    : desactive"
echo "  UFW         : actif"
echo "  fail2ban    : actif"
echo "  Docker      : installe"
echo "============================================================"
echo "IMPORTANT : passwd $USERNAME"
