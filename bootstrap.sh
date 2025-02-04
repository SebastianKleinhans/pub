#!/bin/bash
set -euo pipefail

echo "🔄 Starte vollständige Einrichtung..."

# 1️⃣ Wichtige Pakete installieren
echo "📦 Installiere Basis-Pakete..."
sudo apt update
sudo apt install -y curl wget git zsh tmux neovim aptitude net-tools iputils-ping dnsutils ca-certificates lsb-release gnupg rsync stow

# 2️⃣ Just installieren, falls nicht vorhanden
if ! command -v just &> /dev/null; then
    echo "📦 Installiere 'just'..."
    sudo apt install -y just
fi

# 3️⃣ ChezMoi aus offiziellem Repository installieren
if ! command -v chezmoi &> /dev/null; then
    echo "📦 Installiere 'chezmoi'..."
    sudo apt install -y chezmoi || sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# 4️⃣ Docker Repository hinzufügen, falls nicht vorhanden
if ! dpkg -l | grep -q docker-ce; then
    echo "🐳 Füge Docker-Repository hinzu..."
    sudo apt install -y apt-transport-https software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

# 5️⃣ Justfile laden und ausführen
if [ ! -d "$HOME/dotfiles" ]; then
    echo "🔐 Klone dotfiles Repository..."
    git clone https://github.com/DEINUSERNAME/dotfiles.git "$HOME/dotfiles"
fi

cd "$HOME/dotfiles"
just all

echo "✅ Installation abgeschlossen!"
