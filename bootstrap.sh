#!/bin/bash
set -euo pipefail

echo "🔄 Starte minimales Bootstrapping..."

# 1️⃣ Just installieren (falls nicht vorhanden)
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

# 2️⃣ Prüfen, ob SSH-Schlüssel für Zugriff auf privates Repository existiert
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "❌ Fehler: SSH-Schlüssel ~/.ssh/id_rsa nicht gefunden!"
    exit 1
fi

# 3️⃣ Privates Dotfiles-Repository per SSH klonen (falls nicht vorhanden)
if [ ! -d ~/dotfiles ]; then
    echo "🔐 Klone privates Dotfiles-Repository..."
    export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes"
    git clone git@github.com:SebastianKleinhans/dotfiles.git ~/dotfiles
else
    echo "✅ Dotfiles-Repository bereits vorhanden, überspringe Klonen."
fi

# 4️⃣ Prüfen, ob `justfile` existiert
if [ ! -f ~/dotfiles/justfile ]; then
    echo "❌ Fehler: Kein justfile in ~/dotfiles gefunden!"
    exit 1
fi

# 5️⃣ Starte das vollständige Bootstrapping mit `just`
cd ~/dotfiles
~/bin/just bootstrap

echo "✅ Bootstrapping abgeschlossen!"
