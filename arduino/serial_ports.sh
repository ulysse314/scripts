#!/bin/bash

description="$1"

for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
(
  syspath="${sysdevpath%/dev}"
  devname="$(udevadm info -q name -p $syspath)"
  [[ "$devname" == "bus/"* ]] && continue
  eval "$(udevadm info -q property --export -p $syspath)"
  [[ -z "$ID_SERIAL" ]] && continue
  [[ "${ID_SERIAL}" != "${description}" ]] && continue
  echo "${devname}"
  exit 0
)
done
exit 1
