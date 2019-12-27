#!/bin/bash

key="$1"
description="$2"

for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
  syspath="${sysdevpath%/dev}"
  devname="$(udevadm info -q name -p ${syspath})"
  [[ "${devname}" == "bus/"* ]] && continue
  eval "$(udevadm info -q property --export -p ${syspath})"
  if [[ "${key}" == "ID_MODEL" ]]; then
    [[ -z "${ID_MODEL}" ]] && continue
    [[ "${ID_MODEL}" != "${description}" ]] && continue
    echo "${devname}"
    exit 0
  elif [[ "${key}" == "ID_SERIAL" ]]; then
    [[ -z "${ID_SERIAL}" ]] && continue
    [[ "${ID_SERIAL}" != "${description}" ]] && continue
    echo "${devname}"
    exit 0
  fi
done
exit 1
