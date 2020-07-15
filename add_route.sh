#!/bin/bash

set -x

DEBUG_FILE=/tmp/route
INTERFACE="eth1"
INTERFACE_ROUTER_IP="192.168.8.1"
TEST_IP="8.8.8.8"

while [[ ! `ifconfig "${INTERFACE}"` ]]; do sleep 2; done

DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
echo "Start monitoring with default interface ${DEFAULT_INTERFACE}" > "${DEBUG_FILE}"
while [[ true ]]; do
  ping -I "${INTERFACE}" -c 1 -W 5 "${TEST_IP}"
  if [[ "$?" == "1" ]]; then
    echo "ping failed"
    DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" == "${INTERFACE}" ]]; then
      ip route del default via "${INTERFACE_ROUTER_IP}" dev "${INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Remove default route to ${INTERFACE}" >> "${DEBUG_FILE}"
      DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    fi
  else
    echo "ping succeded"
    DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    if [[ "${DEFAULT_INTERFACE}" != "${INTERFACE}" ]]; then
      ip route add default via "${INTERFACE_ROUTER_IP}" dev "${INTERFACE}" 2>> "${DEBUG_FILE}"
      echo "Add default route to ${INTERFACE}" >> "${DEBUG_FILE}"
      DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
    fi
  fi
  ifconfig "${INTERFACE}" > /dev/null
  INTERFACE_VALID="$?"
  if [[ "${INTERFACE_VALID}" != "0" || "${DEFAULT_INTERFACE}" == "${INTERFACE}" ]]; then
    sleep 5
  fi
done
