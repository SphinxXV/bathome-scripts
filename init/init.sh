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
echo "[1/9] Mise a jour du systeme..."
apt update && apt upgrade -y

# 2. curl et sudo EN PREMIER - peuvent manquer sur Debian minimal
echo "[2/9] Installation de curl et sudo (prioritaire)..."
apt install -y curl sudo

# 3. Outils de base
echo "[3/9] Installation des outils de base..."
apt install -y wget git ufw fail2ban net-tools htop nano

# 4. Creation de l'utilisateur
echo "[4/9] Verification de l'utilisateur $USERNAME..."
if id "$USERNAME" &>/dev/null; then
    echo "  -> Utilisateur $USERNAME existe deja"
else
    adduser --disabled-password --gecos "" $USERNAME
    echo "  -> Utilisateur $USERNAME cree"
fi
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

# 5. Docker
echo "[5/9] Installation de Docker..."
curl -fsSL https://get.docker.com | sh
usermod -aG docker $USERNAME
systemctl enable docker
systemctl start docker

# 6. Firewall UFW
echo "[6/9] Configuration du firewall UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

# 7. fail2ban
echo "[7/9] Configuration de fail2ban..."
systemctl enable fail2ban
systemctl start fail2ban

# 8. Hostname
echo "[8/9] Configuration du hostname..."
hostnamectl set-hostname $HOSTNAME_VM

# 9. Securisation SSH
echo "[9/9] Securisation SSH..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

echo ""
echo "============================================================"
echo "VM $HOSTNAME_VM initialisee avec succes !"
echo "  Utilisateur : $USERNAME"
echo "  Root SSH    : desactive"
echo "  Auth mot de passe SSH : active"
echo "  UFW         : actif"
echo "  fail2ban    : actif"
echo "  Docker      : installe"
echo "============================================================"
echo ""
echo "Depuis ton Mac : ssh $USERNAME@IP_DE_LA_VM"
