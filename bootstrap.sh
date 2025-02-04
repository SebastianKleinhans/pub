set shell := ["bash", "-c"]

install:
	echo "📦 Installiere benötigte Pakete..."
	sudo apt update && sudo apt upgrade -y
	sudo apt install -y \
	git zsh tmux neovim aptitude net-tools iputils-ping bind9-dnsutils \
	curl wget ca-certificates lsb-release gnupg rsync stow software-properties-common

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
	echo "🛠️ Installiere chezmoi direkt von der Quelle..."
	sh -c "$(curl -fsLS get.chezmoi.io)"

bootstrap:
	echo "🔧 Starte vollständiges Bootstrapping..."
	just install
	just docker-install
	just chezmoi-install
	just apply-dotfiles

apply-dotfiles:
	echo "🛠️ Wende Dotfiles mit chezmoi an..."
	chezmoi init --apply git@github.com:SebastianKleinhans/dotfiles.git
	chezmoi apply

update:
	echo "🔄 Führe System-Updates durch..."
	sudo apt update && sudo apt upgrade -y
	chezmoi update --apply

all: bootstrap
