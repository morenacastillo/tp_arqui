#!/bin/bash
clear

###############################
#
# Parámetros:
#  - Lista de Usuarios a crear
#  - Usuario del cual se obtendrá la clave
#
#  Tareas:
#  - Crear los usuarios según la lista recibida en los grupos descriptos
#  - Los usuarios deberán de tener la misma clave que la del usuario pasado por parámetro
#
###############################

LISTA=$1
USUARIO_PARAMETRO=$2
PASSWD=$(sudo grep $USUARIO_PARAMETRO /etc/shadow | awk -F ',' '{print $2}')

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $LISTA | grep -v ^#`
do
    USUARIO=$(echo $LINEA | awk -F ',' '{print $1}')
    GRUPO=$(echo $LINEA | awk -F ',' '{print $2}')
    DIRECTORIO=$(echo $LINEA | awk -F ',' '{print $3}')

    if ! grep -q "^$GRUPO:" /etc/group; then
    	sudo groupadd $GRUPO
    fi
  
    sudo useradd -m -s /bin/bash -g $GRUPO -d $DIRECTORIO $USUARIO


    if [[ -d $DIR_HOME ]]; then
        sudo chown $USUARIO:$GRUPO $DIR_HOME
        sudo chmod 750 $DIR_HOME
    fi

done
IFS=$ANT_IFS

echo
echo "Validación"
grep TP /etc/passwd /etc/group

