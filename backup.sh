#!/bin/bash

set -x

source /etc/ulysse314/script

BACKUP_FOLDER='/root/system/'

rsync_dir() {
  rsync -aqv --delete-after -e "ssh -p ${BACKUP_PORT}" "${1}" "${BACKUP_USER}@${BACKUP_SERVER}:backup/${NAME}/"
}

function update_git {
  REPOSITORY="$1"
  pushd .
  cd "/root/${REPOSITORY}"
  git pull --rebase
  popd
}

if [ "$1" != "" ];  then
    echo "sleep $1"
    sleep "$1"
fi

rsync -aqv --delete-after /etc "${BACKUP_FOLDER}"
apt list --installed > "${BACKUP_FOLDER}packages.txt"
rsync_dir "/root"
rsync_dir "/home/boatpi"
rsync_dir "/boot"

update_git scripts
update_git boat

cp /root/scripts/authorized_keys /root/.ssh/authorized_keys
rsync -aqv --delete-after --exclude "name" -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:ulysse314" "/etc/"
