#!/bin/bash

DEBUG_FILE=/tmp/route
echo "waiting for eth1" > "${DEBUG_FILE}"
while ! ifconfig eth1 ; do sleep 2; done
echo "waiting for 192.168.8.1" >> "${DEBUG_FILE}"
while ! ping -w 2 -c 1 192.168.8.1 ; do sleep 2; done
ip route add default via 192.168.8.1 dev eth1 2>> "${DEBUG_FILE}"
echo "route added" >> "${DEBUG_FILE}"
date >> "${DEBUG_FILE}"
