#!/bin/bash

# Use 4G network in priority against wifi.

set -x

DEBUG_FILE=/tmp/route
G4_INTERFACE="eth1"
WIFI_INTERFACE="wlan0"
TEST_IP="8.8.8.8"
PRIMARY_INTERFACE="${G4_INTERFACE}"
SECONDARY_INTERFACE="${WIFI_INTERFACE}"

while [[ ! `ifconfig "${G4_INTERFACE}"` ]]; do sleep 2; done

echo "Start monitoring with default interface ${DEFAULT_INTERFACE}" > "${DEBUG_FILE}"
while [[ true ]]; do
  sleep 5
  ifconfig "${PRIMARY_INTERFACE}" > /dev/null
  if [[ "$?" != "0" ]]; then
    continue
  fi
  ifconfig "${SECONDARY_INTERFACE}" > /dev/null
  if [[ "$?" != "0" ]]; then
    continue
  fi
  DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
  ping -I "${PRIMARY_INTERFACE}" -c 1 -W 5 "${TEST_IP}"
  IS_PING_VALID="$?"
  if [[ "${IS_PING_VALID}" != "0" && "${DEFAULT_INTERFACE}" == "${PRIMARY_INTERFACE}" ]]; then
    echo "Primary interface fails, and is the default, needs to be lower priority"
    ifmetric "${PRIMARY_INTERFACE}" 201
    ifmetric "${SECONDARY_INTERFACE}" 200
  elif [[ "${IS_PING_VALID}" == "0" && "${DEFAULT_INTERFACE}" == "${SECONDARY_INTERFACE}" ]]; then
    echo "Primary interface works, and is not the default, needs to be higher priority"
    ifmetric "${PRIMARY_INTERFACE}" 200
    ifmetric "${SECONDARY_INTERFACE}" 201
  fi
done
