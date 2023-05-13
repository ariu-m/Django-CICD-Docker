#! /bin/bash

# Variables
DOMAIN=devopshobbies.com
SSH_PORT=1245
BAC_DIR=/opt/backup/file_$NOW

if [-z $BAC_DIR]; then
	echo "Already sxist"
else
	mkdir -p $BAC_DIR
fi

apt update && apt upgrade -y

apt install curl fail2ban ca-certificates gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run hello-world

# disable and mask ufw
systemctl stop ufw
systemctl disable ufw
systemctl mask ufw

cp /etc/fail2ban/fail2ban.conf etc/fail2ban/fail2ban.local
sed -i 's/ssh port/ ssh port=''$SSH_PORT/g' /etc/fail2ban/fail2ban.local

systemctl restart fail2ban
systemctl enable fail2ban
fail2ban-client status
