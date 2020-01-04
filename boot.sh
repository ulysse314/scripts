#!/bin/bash

set -x

source /etc/ulysse314/script

DEBUG_FILE='/tmp/boot.log'
echo "start" > "${DEBUG_FILE}"
date >> "${DEBUG_FILE}"
if [[ "${SSH_4G_PORT}" != "" ]]; then
  SSH_TUNNEL="-R *:${SSH_4G_PORT}:127.0.0.1:22"
fi
if [[ "${CAM_4G_PORT}" != "" ]]; then
  CAM_TUNNEL="-R *:${CAM_4G_PORT}:127.0.0.1:8090"
fi
if [[ "${SSH_TUNNEL_PORT}" != "" ]]; then
  SSH_TUNNEL="-R *:${SSH_TUNNEL_PORT}:127.0.0.1:22"
fi
if [[ "${CAM_TUNNEL_PORT}" != "" ]]; then
  CAM_TUNNEL="-R *:${CAM_TUNNEL_PORT}:127.0.0.1:8090"
fi

#echo "update install" >> "${DEBUG_FILE}"
#date >> "${DEBUG_FILE}"
#/home/ulysse314/scripts/update_install.sh > /tmp/update_install.txt 2>&1
date >> "${DEBUG_FILE}"
AUTOSSH_LOGLEVEL=7 AUTOSSH_LOGFILE='/tmp/autossh.log' /usr/bin/autossh -M 0 -v -f -N -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes ${SSH_TUNNEL} ${CAM_TUNNEL} -p "${TUNNEL_PORT}" "${TUNNEL_USER}@${TUNNEL_SERVER}"
echo "ok" >> "${DEBUG_FILE}"
lsusb >> "${DEBUG_FILE}"
/home/ulysse314/scripts/add_route.sh &
date >> "${DEBUG_FILE}"

if [[ "${CAMERA_ID}" == "PI" ]]; then
  echo "camera: PI" >> "${DEBUG_FILE}"
  #uv4l --driver raspicam --server-option --port=8081 --auto-video_nr --width 640 --height 480 --encoding jpeg -–framerate 30 1&>> "${DEBUG_FILE}"
elif [[ "${CAMERA_ID}" != "" ]]; then
  echo "camera: USB, ${CAMERA_ID}" >> "${DEBUG_FILE}"
  #uv4l --driver uvc --syslog-host localhost --device-id "${CAMERA_ID}" --server-option --port=8081 --auto-video_nr 1&>> "${DEBUG_FILE}"
else
  echo "camera: None"  >> "${DEBUG_FILE}"
fi

echo done >> "${DEBUG_FILE}"
date >> "${DEBUG_FILE}"
/home/ulysse314/boat/start.sh boat "${BOAT_NAME}"
