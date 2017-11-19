#!/bin/bash

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
ssh-keygen -f /root/.ssh/id_rsa -N ""
git config --global user.name "${NAME}"
git config --global user.email "${NAME}"
curl -L "https://raw.githubusercontent.com/ulysse314/scripts/master/authorized_keys" -o /root/.ssh/authorized_keys
git clone git@github.com:ulysse314/scripts.git
git clone git@github.com:ulysse314/boat.git
