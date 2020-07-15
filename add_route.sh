#!/bin/bash

set -x

DEBUG_FILE=/tmp/route
INTERFACE="eth1"
INTERFACE_ROUTER_IP="192.168.8.1"
PING_IP="8.8.4.4"
TEST_IP="8.8.8.8"

check_default_route_for_test_ip() {
  ip route | grep "${PING_IP} via ${INTERFACE_ROUTER_IP} dev ${INTERFACE}"
  if [[ "$?" != "0" ]]; then
    ip route add "${PING_IP}" via "${INTERFACE_ROUTER_IP}" dev "${INTERFACE}" 2>> "${DEBUG_FILE}"
  fi
}

while [[ ! `ifconfig "${INTERFACE}"` ]]; do sleep 2; done
check_default_route_for_test_ip

DEFAULT_INTERFACE=`ip -o route get "${TEST_IP}" | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}'`
echo "Start monitoring with default interface ${DEFAULT_INTERFACE}" > "${DEBUG_FILE}"
while [[ true ]]; do
  ping -I "${INTERFACE}" -c 1 -W 5 "${PING_IP}"
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
  if [[ "${INTERFACE_VALID}" == "0" ]]; then
    check_default_route_for_test_ip
  fi
  if [[ "${INTERFACE_VALID}" != "0" || "${DEFAULT_INTERFACE}" == "${INTERFACE}" ]]; then
    sleep 5
  fi
done
