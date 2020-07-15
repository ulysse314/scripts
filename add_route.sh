#!/bin/bash

# Use 4G network in priority against wifi.

set -x

DEBUG_FILE=/tmp/route
G4_INTERFACE="eth1"
G4_INTERFACE_ROUTER_IP="192.168.8.1"
TEST_IP="8.8.8.8"

while [[ ! `ifconfig "${G4_INTERFACE}"` ]]; do sleep 2; done

DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
echo "Start monitoring with default interface ${DEFAULT_INTERFACE}" > "${DEBUG_FILE}"
while [[ true ]]; do
  ping -I "${G4_INTERFACE}" -c 1 -W 5 "${TEST_IP}"
  if [[ "$?" == "1" ]]; then
    echo "ping failed"
    DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" == "${G4_INTERFACE}" ]]; then
      ip route del default via "${G4_INTERFACE_ROUTER_IP}" dev "${G4_INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Remove default route to ${G4_INTERFACE}" >> "${DEBUG_FILE}"
      DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    fi
  else
    echo "ping succeded"
    DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" != "${G4_INTERFACE}" ]]; then
      ip route add default via "${G4_INTERFACE_ROUTER_IP}" dev "${G4_INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Add default route to ${G4_INTERFACE}" >> "${DEBUG_FILE}"
      DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    fi
  fi
  ifconfig "${G4_INTERFACE}" > /dev/null
  IS_G4_INTERFACE_VALID="$?"
  if [[ "${IS_G4_INTERFACE_VALID}" != "0" || "${DEFAULT_INTERFACE}" == "${G4_INTERFACE}" ]]; then
    sleep 5
  fi
done
