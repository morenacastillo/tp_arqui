#!/bin/bash
clear

###############################
# Validación de URLs con estructura de directorios y logs
#
# Parámetros:
#  - Archivo de entrada con dominios y URLs
#
# Requisitos:
#  - Crear estructura de directorios en /tmp/head-check/
#  - Clasificar las URLs según el código de estado HTTP:
#    * 200 -> ok
#    * 400-499 -> Error/cliente
#    * 500-599 -> Error/servidor
#  - Generar un archivo de log por dominio con el resultado
###############################

LISTA=$1


BASE_DIR="/tmp/head-check"
LOG_FILE="/var/log/status_url.log"
LOG_OK="/temp/ok/dominio.log"

sudo mkdir -p /$BASE_DIR/{Error/{cliente,servidor},ok}

ANT_IFS=$IFS
IFS=$'\n'

for LINEA in `cat $LISTA |  grep -v ^#`
do
#---- Dentro del bucle ----#
  # Obtener el código de estado HTTP
  URL=$(echo $LINEA |awk '{print $2}')
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  # Fecha y hora actual en formato yyyymmdd_hhmmss
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Registrar en el archivo /var/log/status_url.log
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee -a  "$LOG_FILE"

  DOMINIO=$(echo $LINEA |awk '{print $1}')
  if [[ $STATUS_CODE == 200 ]]; then
      DIR="$BASE_DIR/ok/$DOMINIO.log"
  fi

  if [[ $STATUS_CODE -ge 400 && $STATUS_CODE -lt 500 ]]; then
      DIR="$BASE_DIR/Error/cliente/$DOMINIO.log"
  fi

  if [[ $STATUS_CODE -ge 500 && $STATUS_CODE -lt 600 ]]; then
      DIR="$BASE_DIR/Error/servidor/$DOMINIO.log"
  fi

  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" |sudo tee -a  "$LOG_FILE"

#-------------------------#
done
IFS=$ANT_IFS

sudo tree $BASE_DIR


