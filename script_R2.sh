#!/bin/bash
echo "192.168.56.4 testing" | sudo tee -a /etc/hosts
echo "192.168.56.5 production" | sudo tee -a /etc/hosts

if sudo grep -q "^vagrant ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then 
	echo "Los usuarios ya pueden usar sudo sin contraseña"
else
	echo "Agregando configuracion para que los usuarios puedan usar sudo sin contraseña..."
	echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
fi 

sudo apt-get install sshpass

DIRECTORIO_SSH="/home/vagrant/.ssh"

if [ ! -f "$DIRECTORIO_SSH/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f "$DIRECTORIO_SSH/id_ed25519" -N ""
fi

chmod 700 "$DIRECTORIO_SSH"
chmod 600 "$DIRECTORIO_SSH/id_ed25519"

if [ "$(hostname)" == "vmHost1" ]; then
        sshpass -p "vagrant" ssh-copy-id -i "$DIRECTORIO_SSH/id_ed25519.pub" -o StrictHostKeyChecking=no vagrant@192.168.56.5
elif [ "$(hostname)" == "vmHost2" ]; then
        sshpass -p "vagrant" ssh-copy-id -i "$DIRECTORIO_SSH/id_ed25519.pub" -o StrictHostKeyChecking=no vagrant@192.168.56.4
fi
