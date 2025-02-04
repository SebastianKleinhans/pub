---
# Justfile für sicheres Setup mit öffentlichem Bootstrap-Skript
set shell := /bin/bash -euo pipefail

install:
    echo "📦 Installiere benötigte Pakete..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git zsh tmux neovim aptitude net-tools iputils-ping dnsutils curl wget ca-certificates lsb-release gnupg rsync stow chezmoi docker-ce docker-ce-cli containerd.io

bootstrap:
    echo "🔐 Lade privates Repository mit Bootstrap-Skript..."
    chezmoi init --apply git@github.com:DEINUSERNAME/dotfiles-private.git
    chezmoi apply

chezmoi-setup:
    echo "🛠️ Initialisiere und wende chezmoi Konfiguration an..."
    chezmoi apply

docker-wsl:
    echo "⚙️ Konfiguriere Docker für WSL..."
    echo '{"experimental": true, "features": {"buildkit": true}}' | sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker

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

all: install bootstrap docker-wsl ssh-setup
