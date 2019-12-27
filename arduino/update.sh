#!/bin/bash
# update.sh [file_to_compile]

file_to_compile=$1
if [[ "${file_to_compile}" = "" ]]; then
  file_to_compile="/home/ulysse314/boat/arduino/arduino.ino"
fi
feather_id_model="Feather_M0_Express"
feather_ftdi_description="239a_000b"
base_name=`basename "${file_to_compile}"`
build_dir="/tmp/arduino_build/${base_name}"
binary="${build_dir}/${base_name}.bin"

/home/ulysse314/scripts/arduino/compile.sh "${file_to_compile}" "${build_dir}"
if [[ "$?" != 0 ]]; then
  exit 1
fi
while :
do
  feather_port=`/home/ulysse314/scripts/arduino/serial_ports.sh ID_MODEL "${feather_id_model}"`
  if [[ "${feather_port}" != "" ]]; then
    echo "Feather is present, it needs to be reset into FTDI, ${feather_port}."
    /home/ulysse314/scripts/arduino/reset.py "${feather_port}"
  else
    feather_ftdi_port=`/home/ulysse314/scripts/arduino/serial_ports.sh ID_SERIAL "${feather_ftdi_description}"`
    echo "FTDI port: ${feather_ftdi_port}"
    if [[ "${feather_ftdi_port}" != "" ]]; then
      echo "FTDI port found"
      break
    fi
  fi
  echo "Failed, trying again in one second"
  sleep 1
done
/home/ulysse314/scripts/arduino/upload.sh "${binary}" "${feather_ftdi_port}"
if [[ "$?" != 0 ]]; then
  exit 3
fi
echo "=== Updated ==="
