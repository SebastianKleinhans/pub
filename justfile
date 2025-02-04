#!/bin/bash
set shell := ["bash", "-euo", "pipefail"]

echo "🔄 Starte minimales Bootstrapping..."

# 1️⃣ Just installieren (nur wenn nicht vorhanden)
if ! command -v just &> /dev/null; then
    echo "⚡ Installiere 'just' aus offizieller Quelle..."
    mkdir -p ~/bin
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
    export PATH="$HOME/bin:$PATH"
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
else
    echo "✅ 'just' ist bereits installiert, überspringe Installation."
fi


# 2️⃣ Privates Dotfiles-Repository per SSH klonen
echo "🔐 Klone privates Dotfiles-Repository..."
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes"
git clone git@github.com:SebastianKleinhans/dotfiles.git ~/dotfiles

# 3️⃣ Starte das vollständige Bootstrapping mit `just`
cd ~/dotfiles
~/bin/just bootstrap

echo "✅ Bootstrapping abgeschlossen!"
