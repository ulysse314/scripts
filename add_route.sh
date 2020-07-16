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
    # if the primary interface doesn't exist, no need to choose the priority.
    continue
  fi
  ifconfig "${SECONDARY_INTERFACE}" > /dev/null
  if [[ "$?" != "0" ]]; then
    # if the secondary interface doesn't exist, no need to choose the priority.
    continue
  fi
  # Find which is the default interface used right now.
  DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
  ping -I "${PRIMARY_INTERFACE}" -c 1 -W 5 "${TEST_IP}"
  IS_PING_VALID="$?"
  if [[ "${IS_PING_VALID}" != "0" && "${DEFAULT_INTERFACE}" == "${PRIMARY_INTERFACE}" ]]; then
    # The primary interface doesn't work and it is the default interface.
    # So the secondary interface needs to be the default interface.
    ifmetric "${PRIMARY_INTERFACE}" 201
    ifmetric "${SECONDARY_INTERFACE}" 200
  elif [[ "${IS_PING_VALID}" == "0" && "${DEFAULT_INTERFACE}" == "${SECONDARY_INTERFACE}" ]]; then
    # The primary interface works and it is not the default interface.
    # So the primary interface needs to be the default interface.
    ifmetric "${PRIMARY_INTERFACE}" 200
    ifmetric "${SECONDARY_INTERFACE}" 201
  fi
done
