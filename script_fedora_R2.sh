IP_PRODUCCION="192.168.56.5"
NOMBRE_PROD="produccion"

if ! grep -q "$IP_TESTING $NOMBRE_TEST" /etc/hosts; then
        echo "$IP_TESTING $NOMBRE_TEST" | sudo tee -a
fi

if  ! grep -q "$IP_PRODUCCION $NOMBRE_PROD"  /etc/hosts; then
        echo "$IP_PRODUCCION $NOMBRE_PROD" | sudo tee -a
fi

if sudo grep -q "^vagrant ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo "Los usuarios ya pueden usar sudo sin contraseña"
else
        echo "Agregando configuracion para que los usuarios puedan usar sudo sin contraseña..."
        echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
fi

DIRECTORIO_SSH="/home/vagrant/.ssh"

if [ ! -f "$DIRECTORIO_SSH/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f "$DIRECTORIO_SSH/id_ed25519" -N ""
fi

chmod 700 "$DIRECTORIO_SSH"
chmod 600 "$DIRECTORIO_SSH/id_ed25519"

if [ "$(hostname)" == "vmHost1" ]; then
        sshpass -p "vagrant" ssh-copy-id -i "$DIRECTORIO_SSH/id_ed25519.pub" -o StrictHostKeyChecking=no vagrant@192.168.56.106
elif [ "$(hostname)" == "vmHost2" ]; then
        sshpass -p "vagrant" ssh-copy-id -i "$DIRECTORIO_SSH/id_ed25519.pub" -o StrictHostKeyChecking=no vagrant@192.168.56.4
fi
