#!/bin/bash

feather_id="Adafruit_Feather_M0_Express"
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
(
  syspath="${sysdevpath%/dev}"
  devname="$(udevadm info -q name -p $syspath)"
  [[ "$devname" == "bus/"* ]] && continue
  eval "$(udevadm info -q property --export -p $syspath)"
  [[ -z "$ID_SERIAL" ]] && continue
  [[ "${ID_SERIAL}" != "${feather_id}" ]] && continue
  echo "${devname}"
)
done

