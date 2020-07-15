#!/bin/bash

# Use 4G network in priority against wifi.

set -x

DEBUG_FILE=/tmp/route
G4_INTERFACE="eth1"
WIFI_INTERFACE="wlan0"
TEST_IP="8.8.8.8"

while [[ ! `ifconfig "${G4_INTERFACE}"` ]]; do sleep 2; done

echo "Start monitoring with default interface ${DEFAULT_INTERFACE}" > "${DEBUG_FILE}"
while [[ true ]]; do
  ifconfig "${G4_INTERFACE}" > /dev/null
  IS_G4_INTERFACE_VALID="$?"
  if [[ "${IS_G4_INTERFACE_VALID}" == "0" ]]; then
    DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    ping -I "${G4_INTERFACE}" -c 1 -W 5 "${TEST_IP}"
    if [[ "$?" == "1" && "${DEFAULT_INTERFACE}" == "${G4_INTERFACE}" ]]; then
      echo "Decrease 4G"
      ifmetric "${G4_INTERFACE}" 201
      ifmetric "${WIFI_INTERFACE}" 200
    elif [[ "$?" == "0" && "${DEFAULT_INTERFACE}" == "${WIFI_INTERFACE}" ]]; then
      echo "Increase 4G"
      ifmetric "${G4_INTERFACE}" 200
      ifmetric "${WIFI_INTERFACE}" 201
    fi
  fi
  sleep 5
done
