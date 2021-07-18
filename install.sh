#!/bin/bash
# install.sh boat_name backup_user backup_server backup_port public_key_server

set -x

DEFAULT_USER=ulysse314
BOAT_NAME="$1"
BACKUP_USER="$2"
BACKUP_SERVER="$3"
BACKUP_PORT="$4"
PUBLIC_KEY_SERVER="$5"

if [[ $EUID != 0 ]]; then
    echo "Please run as root"
    exit
fi

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
curl -L "https://raw.githubusercontent.com/ulysse314/scripts/master/linux/authorized_keys" -o /root/.ssh/authorized_keys

apt update
apt install -y git

if [ ! -f /root/.ssh/known_hosts ] && [ "${BACKUP_SERVER}" != "" ] && [ "${BACKUP_PORT}" != "" ]; then
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
    echo "DEFAULT_USER='${DEFAULT_USER}'" >> /etc/ulysse314/script
    echo "MAIN_DIR='/home/${DEFAULT_USER}'" >> /etc/ulysse314/script
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
source /etc/ulysse314/script

userdel -r pi
if [ ! -d "/home/${DEFAULT_USER}" ]; then
  useradd -m -G sudo "${DEFAULT_USER}"
fi
if [ ! -d "/home/${DEFAULT_USER}/.ssh" ]; then
  mkdir "/home/${DEFAULT_USER}/.ssh"
  chown "${DEFAULT_USER}:${DEFAULT_USER}" "/home/${DEFAULT_USER}/.ssh"
  chmod 0700 "/home/${DEFAULT_USER}/.ssh"
fi

git config --global user.name "${BOAT_NAME}"
git config --global user.email "${BOAT_NAME}"
cd "${MAIN_DIR}"
if [ ! -d "${MAIN_DIR}/scripts" ]; then
  git clone "https://github.com/ulysse314/scripts.git"
else
  cd "scripts"
  git pull --rebase
fi

"/home/${DEFAULT_USER}/scripts/update_install.sh"
