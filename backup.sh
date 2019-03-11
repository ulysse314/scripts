#!/bin/bash

set -x

source /etc/ulysse314/script

BACKUP_FOLDER='${MAIN_DIR}/system/'
SCRIPT_DIR=`dirname "$0"`
"${SCRIPT_DIR}/update_install.sh"

rsync_for_backup() {
  rsync -aqv --delete-after -e "ssh -p ${BACKUP_PORT}" "${1}" "${BACKUP_USER}@${BACKUP_SERVER}:backup/${BOAT_NAME}/"
}

if [ "$1" != "" ];  then
    echo "sleep $1"
    sleep "$1"
fi

rsync -aqv --delete-after /etc "${BACKUP_FOLDER}"
apt list --installed > "${BACKUP_FOLDER}packages.txt"
rsync_for_backup "/root"
rsync_for_backup "${MAIN_DIR}"
rsync_for_backup "/boot"
date | ssh -p ${BACKUP_PORT} "${BACKUP_USER}@${BACKUP_SERVER}" "cat > backup/${BOAT_NAME}/last_backup"

if [[ `cat "${MAIN_DIR}/boat/arduino/Version.h" | cksum` != `cat "${MAIN_DIR}/.arduino_version" | cksum` ]]; then
  "${MAIN_DIR}/scripts/arduino/update.sh"
  if [[ "$?" == "0" ]]; then
    cp "${MAIN_DIR}/boat/arduino/Version.h" "${MAIN_DIR}/.arduino_version"
  fi
fi
