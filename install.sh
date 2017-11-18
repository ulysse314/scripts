#!/bin/bash

PYTHON="Python-3.6.3"

if [ "$1" == "" ]; then
    echo "No name"
    exit 1
fi

echo "$1" > /etc/hostname
hostname "$1"
apt-get update
apt-get upgrade -y
apt-get install emacs-nox python3 autossh screen git
ssh-keygen -f /root/.ssh/id_rsa -N ""
git config --global user.name "telemaque"
git config --global user.email "telemaque"
curl -L "https://raw.githubusercontent.com/ulysse314/install/master/authorized_keys" -o /root/.ssh/authorized_keys
