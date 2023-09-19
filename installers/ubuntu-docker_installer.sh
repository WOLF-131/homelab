#! /bin/bash

# wget -O- https://raw.githubusercontent.com/wolf-131/homelab/main/installers/ubuntu-docker_installer.sh | bash

# Colors
Yellow='\033[0;33m'
Cyan='\033[0;36m'
NC='\033[0m' # No Color

# Installer file to setup ubuntu server
echo -e "${Yellow}UPDATE SYSTEM${NC}"
sudo apt update
sudo NEEDRESTART_MODE=a apt upgrade -y

# Set hostname
read -p "${Cyan}Set Hostname?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "${Cyan}Enter hostname for server:${NC} " hostname
  echo
  sudo hostnamectl set-hostname $hostname
fi

# Set static IP Address
read -p "${Cyan}Set static IP?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "${Cyan}Enter IP Address for server(192.168.xxx.xxx/xx):${NC} " address
  echo
  echo "network:
    version: 2
    renderer: networkd
    ethernets:
    ens3:
      dhcp4: no
      addresses:
        - $address
      gateway4: 192.168.5.1
      nameservers:
          addresses: [192.168.1.3, 1.1.1.1]" | sudo tee -a /etc/netplan/01-netcfg.yaml > /dev/null
fi

# Import ssh keys from github
read -p "${Cyan}Import ssh keys from github?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${Yellow}Importing ssh keys${NC}"
  sudo ssh-import-id-gh wolf-131
fi

# Install base packages
read -p "${Cyan}Install base packages?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${Yellow}Installing base packages${NC}"
  sudo apt install -y tldr kitty-terminfo nano neofetch htop nfs-common
  tldr -u
fi

# Install ufw
read -p "${Cyan}Install ufw?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${Yellow}Installing ufw${NC}"
  sudo apt install -y ufw
  sudo ufw allow ssh
  sudo ufw allow http
  sudo ufw --force enable
fi

# Install zsh
read -p "${Cyan}Install zsh?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${Yellow}Installing zsh${NC}"
  sudo apt install -y zsh
  sudo chsh -s $(which zsh) $(whoami)
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install docker
read -p "${Cyan}Install docker?${NC} " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${Yellow}Installing docker${NC}"
  sudo apt install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update

  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  sudo usermod -aG docker $USER

  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  sudo apt install -y docker-compose-plugin
fi
