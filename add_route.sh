#!/bin/bash

DEBUG_FILE=/tmp/route
INTERFACE="eth1"
PING_IP="8.8.8.8"

echo "waiting for ${INTERFACE}" > "${DEBUG_FILE}"
while [[ ! `ifconfig "${INTERFACE}"` ]]; do
  sleep 2
done

echo "Start monitoring" > "${DEBUG_FILE}"
while [[ true ]]; do
  ping -I "${INTERFACE}" -c 1 "${PING_IP}"
  if [[ "$?" == "1" ]]; then
    DEFAULT_INTERFACE=`ip -o route get "${PING_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" == "${INTERFACE}" ]]; then
      ip route del default via 192.168.8.1 dev "${INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Remove default route to ${INTERFACE}" > "${DEBUG_FILE}"
    fi
  else
    DEFAULT_INTERFACE=`ip -o route get "${PING_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" == "${INTERFACE}" ]]; then
      ip route add default via 192.168.8.1 dev "${INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Add default route to ${INTERFACE}" > "${DEBUG_FILE}"
    fi
  fi
  sleep 5
done
