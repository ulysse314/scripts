#!/bin/bash
# install.sh boat_name backup_user backup_server backup_port public_key_server

set -x

function update_git {
  REPOSITORY="$1"
  URL="https://github.com/ulysse314/${REPOSITORY}.git"
  pushd .
  cd /home/ulysse314
  if [ ! -d "/home/ulysse314/${REPOSITORY}" ]; then
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
apt-get install -y emacs-nox python3 autossh screen git arduino-mk python3-aiohttp python3-xmltodict gpsd python3-psutil python3-pip munin nginx
pip3 install pyserial-asyncio
pip3 install adafruit-pca9685

if [ ! -f /root/.ssh/known_hosts ] && [ "${BACKUP_SERVER}" != "" ] && [ "${BACKUP_PORT}" != "" ] && [ "${PUBLIC_KEY_SERVER}" != "" ]; then
  ssh-keyscan -p "${BACKUP_PORT}" "${BACKUP_SERVER}" | grep -v "\#" > /root/.ssh/known_hosts
fi
if [ ! -d /etc/ulysse314 ]; then
  mkdir /etc/ulysse314
fi
if [ ! -f /etc/ulysse314/script ]; then
  if [ "${BACKUP_USER}" != "" ] && [ "${BACKUP_SERVER}" != "" ] && [ "${BACKUP_PORT}" != "" ]; then
    echo 'BOAT_NAME=`cat /etc/ulysse314/name`' > /etc/ulysse314/script
    echo "BACKUP_USER='${BACKUP_USER}'" >> /etc/ulysse314/script
    echo "BACKUP_SERVER='${BACKUP_SERVER}'" >> /etc/ulysse314/script
    echo "BACKUP_PORT='${BACKUP_PORT}'" >> /etc/ulysse314/script
  else
    echo "Needs /etc/ulysse314/script"
    exit 1
  fi
fi
if [ ! -f /etc/ulysse314/name ]; then
  echo "${BOAT_NAME}" > /etc/ulysse314/name
  echo "${BOAT_NAME}" > /etc/hostname
  hostname "${BOAT_NAME}"
fi

userdel -r pi
useradd -m -G sudo ulysse314
mkdir /home/ulysse314/.ssh
chown ulysse314:ulysse314 /home/ulysse314/.ssh
chmod 0700 /home/ulysse314/.ssh

git config --global user.name "${BOAT_NAME}"
git config --global user.email "${BOAT_NAME}"
update_git scripts
update_git boat

cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
cat /tmp/crontab > /etc/crontab
cat /home/ulysse314/scripts/crontab >> /etc/crontab

ln -s /home/ulysse314/scripts/munin_plugin.py /etc/munin/plugins/ulysse314.py
ln -s /var/cache/munin/www /var/www/html/munin

/home/ulysse314/scripts/backup.sh
