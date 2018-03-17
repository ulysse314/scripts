#!/bin/bash

set -x

source /etc/ulysse314/script

BACKUP_FOLDER='/home/ulysse314/system/'

rsync_for_backup() {
  rsync -aqv --delete-after -e "ssh -p ${BACKUP_PORT}" "${1}" "${BACKUP_USER}@${BACKUP_SERVER}:backup/${BOAT_NAME}/"
}

function update_git {
  REPOSITORY="$1"
  pushd .
  cd "/home/ulysse314/${REPOSITORY}"
  git pull --rebase
  popd
}

if [ "$1" != "" ];  then
    echo "sleep $1"
    sleep "$1"
fi

update_git scripts
update_git boat

cp /home/ulysse314/scripts/authorized_keys /root/.ssh/authorized_keys
cp /home/ulysse314/scripts/authorized_keys /home/ulysse314/.ssh/authorized_keys
chown ulysse314:ulysse314 /home/ulysse314/.ssh/authorized_keys
scp -P "${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:known_hosts" /root/.ssh/known_hosts
rsync -aqv --delete-after --exclude "name" -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:ulysse314" "/etc/"

rsync -aqv --delete-after /etc "${BACKUP_FOLDER}"
apt list --installed > "${BACKUP_FOLDER}packages.txt"
rsync_for_backup "/root"
rsync_for_backup "/home/ulysse314"
rsync_for_backup "/boot"
