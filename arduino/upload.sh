#!/bin/bash
# upload.sh [file_to_upload] [port]

file_to_upload="$1"
port="$2"

if [[ "${file_to_upload}" = "" ]]; then
  file_to_upload="/tmp/arduino_build/arduino.ino/arduino.ino.bin"
fi
if [[ "${port}" = "" ]]; then
  port=`/home/ulysse314/scripts/arduino/serial_ports.sh "239a_000b"`
fi

/home/ulysse314/arduino/arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d "--port=${port}" -U true -i -e -w -v "${file_to_upload}" -R
exit $?
