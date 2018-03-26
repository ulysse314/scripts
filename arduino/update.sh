#!/bin/bash

feather_description="Adafruit_Feather_M0_Express"
feather_ftdi_description="239a_000b"

/home/ulysse314/scripts/arduino/compile.sh
if [ "$?" != 0 ]; then
  exit 1
fi
while :
do
  feather_port=`/home/ulysse314/scripts/arduino/serial_ports.sh "${feather_description}"`
  if [ "$feather_port" != "" ]; then
    /home/ulysse314/scripts/arduino/reset.py "${feather_port}"
  else
    feather_ftdi_port=`/home/ulysse314/scripts/arduino/serial_ports.sh "${feather_ftdi_description}"`
    if [ "$feather_ftdi_port" != "" ]; then
      break
    fi
  fi
  sleep 1
done
/home/ulysse314/scripts/arduino/upload.sh "${feather_ftdi_port}"
if [ "$?" != 0 ]; then
  exit 3
fi
echo "=== Updated ==="
