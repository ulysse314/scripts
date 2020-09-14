#!/bin/bash
# update.sh [ino_file_path]

INO_FULL_PATH=$1

if [[ "${INO_FULL_PATH}" = "" ]]; then
  INO_FULL_PATH="/home/ulysse314/boat/arduino/arduino.ino"
fi
FEATHER_ID_MODEL="Feather_M0_Express"
FEATHER_ID_MODEL_BIS="Feather_M0"
FEATHER_FTDI_DESCRIPTION="239a_000b"

/home/ulysse314/scripts/arduino/compile.sh "${INO_FULL_PATH}"
if [[ "$?" != 0 ]]; then
  exit 1
fi
while :
do
  echo "Searching for ID_MODEL: ${FEATHER_ID_MODEL}"
  FEATHER_PORT=`/home/ulysse314/scripts/arduino/serial_ports.sh ID_MODEL "${FEATHER_ID_MODEL}"`
  if [[ "${FEATHER_PORT}" == "" ]]; then
    echo "Searching for ID_MODEL: ${FEATHER_ID_MODEL_BIS}"
    FEATHER_PORT=`/home/ulysse314/scripts/arduino/serial_ports.sh ID_MODEL "${FEATHER_ID_MODEL_BIS}"`
  fi
  if [[ "${FEATHER_PORT}" != "" ]]; then
    echo "Feather is present, it needs to be reset into FTDI, ${FEATHER_PORT}."
    /home/ulysse314/scripts/arduino/reset.py "${FEATHER_PORT}"
  else
    FEATHER_FTDI_PORT=`/home/ulysse314/scripts/arduino/serial_ports.sh ID_SERIAL "${FEATHER_FTDI_DESCRIPTION}"`
    echo "FTDI port: ${FEATHER_FTDI_PORT}"
    if [[ "${FEATHER_FTDI_PORT}" != "" ]]; then
      echo "FTDI port found"
      break
    fi
  fi
  echo "Failed, trying again in one second"
  sleep 1
done
/home/ulysse314/scripts/arduino/upload.sh "${INO_FULL_PATH}" "${FEATHER_FTDI_PORT}"
if [[ "$?" != 0 ]]; then
  exit 3
fi
echo "=== Updated ==="
