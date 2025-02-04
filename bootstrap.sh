#!/bin/bash
sudo apt update && sudo apt install -y git ansible
git clone git@github.com:SebastianKleinhans/ansible-wsl-setup.git ~/ansible-wsl-setup
cd ~/ansible-wsl-setup
ansible-playbook setup.yml
