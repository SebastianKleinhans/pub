# Justfile für sicheres Setup mit öffentlichem Bootstrap-Skript
set shell := /bin/bash -euo pipefail

install:
    echo "📦 Installiere benötigte Pakete..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y \
        git zsh tmux neovim aptitude net-tools iputils-ping bind9-dnsutils \
        curl wget ca-certificates lsb-release gnupg rsync stow software-properties-common

just-install:
    echo "⚡ Installiere just aus Pre-Build Binary von GitHub..."
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) JUST_ARCH=amd64 ;;
        aarch64) JUST_ARCH=arm64 ;;
        *) echo "❌ Nicht unterstützte Architektur: $ARCH"; exit 1 ;;
    esac
    curl -fsSL "https://github.com/casey/just/releases/latest/download/just-$(uname -s)-$JUST_ARCH.tar.gz" | tar -xz -C /usr/local/bin just
    chmod +x /usr/local/bin/just

docker-install:
    echo "🐳 Installiere Docker nach offizieller Dokumentation..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    newgrp docker

chezmoi-install:
    echo "🛠️ Installiere chezmoi, falls nicht vorhanden..."
    if ! command -v chezmoi &> /dev/null; then
        sudo apt install -y chezmoi || sh -c "$(curl -fsLS get.chezmoi.io)"
    fi

bootstrap:
    echo "🔐 Lade privates Repository mit Bootstrap-Skript..."
    export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes"
    chezmoi init --apply git@github.com:SebastianKleinhans/dotfiles.git
    chezmoi apply

update:
    echo "🔄 Führe Update durch..."
    sudo apt update && sudo apt upgrade -y
    chezmoi update --apply

all: install just-install docker-install chezmoi-install bootstrap
