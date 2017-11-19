#!/bin/bash

set -x

source /etc/ulysse314/script

SSH_WIFI="-R *:${SSH_WIFI_PORT}:127.0.0.1:22"
SSH_4G="-R *:${SSH_4G_PORT}:127.0.0.1:22"

AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/wifi_autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_WIFI} -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
echo "ok" > /tmp/test
while ! ifconfig eth1 ; do sleep 1; done
echo "1" >> /tmp/test
while ! ping -w 2 -c 1 192.168.8.1 ; do sleep 1; done
echo 2 >> /tmp/test
ip route add default via 192.168.8.1 dev eth1
echo 3 >> /tmp/test
AUTOSSH_LOGFILE='/tmp/4g_autossh.log'
/usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_4G} -b 192.168.8.100 -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
echo done >> /tmp/test
