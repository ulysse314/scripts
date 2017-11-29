#!/bin/bash
# install.sh boat_name backup_user backup_server backup_port public_key_server

set -x

function update_git {
  REPOSITORY="$1"
  pushd .
  cd /root
  if [ ! -d "/root/${REPOSITORY}" ]; then
    git clone "git@github.com:ulysse314/${REPOSITORY}.git"
  else
    cd "${REPOSITORY}"
    git pull --rebase
  fi
  popd
}

if [ ! -f /root/.ssh/id_rsa ]; then
  if [ "$5" != "" ]; then
    echo "No server to send public key"
    exit 1
  fi
  ssh-keygen -f /root/.ssh/id_rsa -N "" -C "$1"
  curl -L --data "`cat /root/.ssh/id_rsa.pub`" "http://$5/public_key" > /dev/null
fi
cat /root/.ssh/id_rsa.pub
curl -L "https://raw.githubusercontent.com/ulysse314/scripts/master/authorized_keys" -o /root/.ssh/authorized_keys

apt-get update
apt-get upgrade -y
apt-get install -y emacs-nox python3 autossh screen git arduino-mk

if [ ! -f /root/.ssh/known_hosts ] && [ "$3" != ""] && [ "$4" != ""] && [ "$5" != "" ]; then
  ssh-keyscan -p "$4" "$3" | grep -v "\#" > /root/.ssh/known_hosts
  ssh-keyscan "$5" | grep -v "\#" >> /root/.ssh/known_hosts
  ssh-keyscan "github.com" | grep -v "\#" >> /root/.ssh/known_hosts
fi
if [ ! -d /etc/ulysse314 ] && [ "$2" != ""] && [ "$3" != ""] && [ "$4" != ""]; then
  scp -r -P "$4" "$2@$3:ulysse314" /etc
fi
if [ ! -f /etc/ulysse314/script ]; then
  echo "Need /etc/ulysse314/script"
  exit 1
fi
if [ ! -f /etc/ulysse314/ulysse314.ini ]; then
  echo "Need /etc/ulysse314/ulysse314.ini"
  exit 1
fi
if [ -f  /etc/ulysse314/name ]; then
  BOAT_NAME=`cat /etc/ulysse314/name`
elif [ "$1" == "" ]; then
  echo "No name"
  exit 1
else
  BOAT_NAME="$1"
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
