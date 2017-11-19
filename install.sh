#!/bin/bash

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

if [ "$1" == "" ]; then
    echo "No name"
    exit 1
fi

NAME="$1"
echo "${NAME}" > /etc/hostname
hostname "${NAME}"
apt-get update
apt-get upgrade -y
apt-get install emacs-nox python3 autossh screen git
userdel -r pi

if [ ! -f /root/.ssh/id_rsa ]; then
  ssh-keygen -f /root/.ssh/id_rsa -N ""
fi
cat /root/.ssh/id_rsa.pub
curl -L "https://raw.githubusercontent.com/ulysse314/scripts/master/authorized_keys" -o /root/.ssh/authorized_keys

git config --global user.name "${NAME}"
git config --global user.email "${NAME}"
update_git scripts
scripts boat

cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
cat /tmp/crontab > /etc/crontab
cat /root/scripts/crontab >> /etc/crontab
