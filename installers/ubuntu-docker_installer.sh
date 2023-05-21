#! /bin/bash

# wget -O- https://raw.githubusercontent.com/wolf-131/homelab/main/installers/ubuntu-docker_installer.sh | bash

# Colors
Yellow='\033[0;33m'
Cyan='\033[0;36m'
NC='\033[0m' # No Color

# Installer file to setup ubuntu servert for docker compose

echo -e "${Yellow}UPDATE SYSTEM${NC}"
sudo apt update
sudo NEEDRESTART_MODE=a apt upgrade -y

# inport ssh keys from github
echo -e "${Yellow}Import ssh keys${NC}"
sudo ssh-import-id-gh wolf-131

# Install base packages
echo -e "${Yellow}Install base packages${NC}"
sudo apt install -y tldr kitty-terminfo nano neofetch htop nfs-common rsync
sudo systemctl enable rsync.service
sudo systemctl start rsync.service
tldr -u

# Install ufw
echo -e "${Yellow}Install ufw${NC}"
sudo apt install -y ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw --force enable

# Install zsh
echo -e "${Yellow}Install zsh${NC}"
sudo apt install -y zsh
sudo chsh -s $(which zsh) $(whoami)
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install docker
echo -e "${Yellow}Install docker${NC}"
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo apt install -y docker-compose-plugin
