#!/bin/bash
# update_install.sh

set -x

source /etc/ulysse314/script

cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
cat /tmp/crontab > /etc/crontab
cat /home/ulysse314/scripts/crontab >> /etc/crontab

if [ ! -e /etc/munin/plugins/ulysse314.py ]; then
  ln -s /home/ulysse314/scripts/linux/munin_plugin.py /etc/munin/plugins/ulysse314.py
fi

if [ ! -f /etc/udev/rules.d/99-feather-symlink.rules ]; then
  ln -s /home/ulysse314/scripts/linux/udev-rules /etc/udev/rules.d/99-feather-symlink.rules
fi

if [ ! -d /home/ulysse314/arduino ]; then
  mkdir /home/ulysse314/arduino
fi
if [ ! -d /home/ulysse314/arduino/libraries ]; then
  mkdir /home/ulysse314/arduino/libraries
fi
