#! /bin/bash

# Installer file to setup ubuntu servert for docker compose

sudo apt update
sudo apt upgrade

# inport ssh keys from github
sudo ssh-import-id-gh wolf-131

# Install base packages
sudo apt install tldr kitty-terminfo nano neofetch htop nfs-common

# Install ufw
sudo apt install ufw
sudo ufw allow ssh
sudo ufw allow http
sudo ufw enable

# Install zsh
sudo apt install zsh
chsh -s $(which zsh)
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install docker
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo apt-get install docker-compose-plugin