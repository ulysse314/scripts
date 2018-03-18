#!/bin/bash
# update_install.sh

set -x

source /etc/ulysse314/script

cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
cat /tmp/crontab > /etc/crontab
cat /home/ulysse314/scripts/crontab >> /etc/crontab

if [ -f /etc/munin/plugins/ulysse314.py ]; then
  rm /etc/munin/plugins/ulysse314.py
fi
ln -s /home/ulysse314/scripts/linux/munin_plugin.py /etc/munin/plugins/ulysse314.py

if [ ! -f /etc/udev/rules.d/99-feather-symlink.rules ]; then
  ln -s /home/ulysse314/scripts/linux/udev-rules /etc/udev/rules.d/99-feather-symlink.rules
fi
