# Justfile für sicheres Setup mit öffentlichem Bootstrap-Skript
set shell := /bin/bash -euo pipefail

install:
    echo "📦 Installiere benötigte Pakete..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git zsh tmux neovim aptitude net-tools iputils-ping dnsutils curl wget ca-certificates lsb-release gnupg rsync stow chezmoi

docker-install:
    echo "🐳 Installiere Docker nach offizieller Docker-Dokumentation..."
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

bootstrap:
    echo "🔐 Lade privates Repository mit Bootstrap-Skript..."
    chezmoi init --apply git@github.com:SebastianKleinhans/dotfiles.git
    chezmoi apply

chezmoi-setup:
    echo "🛠️ Initialisiere und wende chezmoi Konfiguration an..."
    chezmoi apply

ssh-setup:
    echo "🔐 Entschlüssele SSH-Keys mit GPG..."
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    gpg --batch --yes --decrypt --output ~/.ssh/id_rsa ~/dotfiles/id_rsa.gpg
    chmod 600 ~/.ssh/id_rsa
    gpg --batch --yes --decrypt --output ~/.ssh/id_rsa.pub ~/dotfiles/id_rsa.pub.gpg
    chmod 644 ~/.ssh/id_rsa.pub

update:
    echo "🔄 Führe Update durch..."
    sudo apt update && sudo apt upgrade -y
    chezmoi update --apply

all: install docker-install bootstrap ssh-setup
