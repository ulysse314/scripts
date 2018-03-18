#!/bin/bash

set -x

source /etc/ulysse314/script

DEBUG_FILE='/tmp/test'
SSH_WIFI="-R *:${SSH_WIFI_PORT}:127.0.0.1:22"
SSH_4G="-R *:${SSH_4G_PORT}:127.0.0.1:22"

/home/ulysse314/scripts/update_install.bash
AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/wifi_autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_WIFI} -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
echo "ok" > "${DEBUG_FILE}"
lsusb >> "${DEBUG_FILE}"
/home/ulysse314/scripts/add_route.sh &
AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/4g_autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_4G} -b 192.168.8.100 -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
date >> "${DEBUG_FILE}"
echo done >> "${DEBUG_FILE}"
/home/ulysse314/boat/start.sh boat "${BOAT_NAME}"
