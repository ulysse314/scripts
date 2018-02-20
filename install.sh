#!/bin/bash
# install.sh boat_name backup_user backup_server backup_port public_key_server

set -x

function update_git {
  REPOSITORY="$1"
  URL="https://github.com/ulysse314/${REPOSITORY}.git"
  pushd .
  cd /root
  if [ ! -d "/root/${REPOSITORY}" ]; then
    git clone "${URL}"
  else
    cd "${REPOSITORY}"
    git pull --rebase
  fi
  popd
}

BOAT_NAME="$1"
BACKUP_USER="$2"
BACKUP_SERVER="$3"
BACKUP_PORT="$4"
PUBLIC_KEY_SERVER="$5"

if [ "${BOAT_NAME}" == "" ]; then
  if [ ! -f /etc/ulysse314/name ]; then
    echo "No name"
    exit 1
  fi
  BOAT_NAME=`cat /etc/ulysse314/name`
fi

if [ ! -f /root/.ssh/id_rsa ]; then
  if [ "${PUBLIC_KEY_SERVER}" == "" ]; then
    echo "No server to send public key"
    exit 1
  fi
  ssh-keygen -f /root/.ssh/id_rsa -N "" -C "${BOAT_NAME}"
  curl -L --data "`cat /root/.ssh/id_rsa.pub`" "http://www.${PUBLIC_KEY_SERVER}/public_key" > /dev/null
fi
cat /root/.ssh/id_rsa.pub
curl -L "https://raw.githubusercontent.com/ulysse314/scripts/master/authorized_keys" -o /root/.ssh/authorized_keys

apt-get update
apt-get upgrade -y
apt-get install -y emacs-nox python3 autossh screen git arduino-mk python3-aiohttp python3-xmltodict gpsd python3-psutil python3-pip
pip3 install pyserial-asyncio
pip3 install adafruit-pca9685

if [ ! -f /root/.ssh/known_hosts ] && [ "${BACKUP_SERVER}" != "" ] && [ "${BACKUP_PORT}" != "" ] && [ "${PUBLIC_KEY_SERVER}" != "" ]; then
  ssh-keyscan -p "${BACKUP_PORT}" "${BACKUP_SERVER}" | grep -v "\#" > /root/.ssh/known_hosts
  ssh-keyscan "${PUBLIC_KEY_SERVER}" | grep -v "\#" >> /root/.ssh/known_hosts
  ssh-keyscan "github.com" | grep -v "\#" >> /root/.ssh/known_hosts
fi
if [ ! -d /etc/ulysse314 ] && [ "${BACKUP_USER}" != "" ] && [ "${BACKUP_SERVER}" != "" ] && [ "${BACKUP_PORT}" != "" ]; then
  scp -r -P "${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:ulysse314" /etc
fi
if [ ! -f /etc/ulysse314/script ]; then
  echo "Need /etc/ulysse314/script"
  exit 1
fi
if [ ! -f /etc/ulysse314/ulysse314.json ]; then
  echo "Need /etc/ulysse314/ulysse314.json"
  exit 1
fi
if [ ! -f /etc/ulysse314/name ]; then
  echo "${BOAT_NAME}" > /etc/ulysse314/name
  echo "${BOAT_NAME}" > /etc/hostname
  hostname "${BOAT_NAME}"
fi

userdel -r pi

git config --global user.name "${BOAT_NAME}"
git config --global user.email "${BOAT_NAME}"
update_git scripts
update_git boat

cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
cat /tmp/crontab > /etc/crontab
cat /root/scripts/crontab >> /etc/crontab
