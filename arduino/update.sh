#!/bin/bash

port=`/home/ulysse314/scripts/arduino/serial_ports.sh`

/home/ulysse314/scripts/arduino/compile.sh
if [ "$?" != 0 ]; then
  exit 1
fi
/home/ulysse314/scripts/arduino/reset.py "${port}"
if [ "$?" != 0 ]; then
  exit 2
fi
sleep 2
/home/ulysse314/scripts/arduino/upload.sh "${port}"
if [ "$?" != 0 ]; then
  exit 3
fi
