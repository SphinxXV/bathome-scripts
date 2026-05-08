#!/bin/bash
# =============================================================
# B@tHome — init.sh
# Script de base commun a toutes les VMs Debian 13
# Usage: bash init.sh <username> <hostname>
# =============================================================

set -e

USERNAME=$1
HOSTNAME=$2

if [ -z "$USERNAME" ] || [ -z "$HOSTNAME" ]; then
  echo "Usage: bash init.sh <username> <hostname>"
    exit 1
    fi

    echo "==> Configuration de base pour $HOSTNAME..."

    # Hostname
    hostnamectl set-hostname "$HOSTNAME"
    echo "127.0.1.1 $HOSTNAME" >> /etc/hosts

    # Mise a jour systeme
    apt-get update -qq && apt-get upgrade -y -qq

    # Paquets essentiels - sudo et curl inclus des le depart
    apt-get install -y -qq \
      sudo \
        curl \
          wget \
            git \
              ufw \
                fail2ban \
                  unattended-upgrades \
                    apt-listchanges \
                      ca-certificates \
                        gnupg \
                          lsb-release \
                            htop \
                              vim \
                                net-tools

                                # Creer utilisateur si inexistant
                                if ! id "$USERNAME" &>/dev/null; then
                                  useradd -m -s /bin/bash "$USERNAME"
                                    echo "==> Utilisateur $USERNAME cree — definissez son mot de passe :"
                                      passwd "$USERNAME"
                                      fi

                                      # Sudo sans mot de passe pour l'utilisateur
                                      echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
                                      chmod 440 /etc/sudoers.d/$USERNAME

                                      # Docker
                                      curl -fsSL https://get.docker.com | bash
                                      usermod -aG docker "$USERNAME"

                                      # UFW — pare-feu
                                      ufw default deny incoming
                                      ufw default allow outgoing
                                      ufw allow 22/tcp comment 'SSH'
                                      ufw --force enable

                                      # Fail2ban — protection SSH brute force
                                      cat > /etc/fail2ban/jail.local << 'F2B'
                                      [sshd]
                                      enabled = true
                                      port = 22
                                      maxretry = 5
                                      bantime = 3600
                                      findtime = 600
                                      F2B
                                      systemctl enable fail2ban
                                      systemctl restart fail2ban

                                      # Mises a jour automatiques de securite
                                      cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'UPG'
                                      Unattended-Upgrade::Allowed-Origins {
                                        "${distro_id}:${distro_codename}-security";
                                        };
                                        Unattended-Upgrade::AutoFixInterruptedDpkg "true";
                                        Unattended-Upgrade::Remove-Unused-Dependencies "true";
                                        Unattended-Upgrade::Automatic-Reboot "false";
                                        UPG

                                        # SSH — durcissement
                                        sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
                                        sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
                                        sed -i 's/#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
                                        systemctl restart sshd

                                        # Node Exporter
                                        bash <(curl -fsSL https://raw.githubusercontent.com/SphinxXV/bathome-scripts/main/init/node_exporter.sh)

                                        echo ""
                                        echo "==> Init terminee pour $HOSTNAME !"
                                        echo "    Utilisateur : $USERNAME"
                                        echo "    Node Exporter : http://$(hostname -I | awk '{print $1}'):9100/metrics"
                                        echo "    Attention : root SSH desactive — utilisez $USERNAME"
