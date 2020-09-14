#!/bin/bash
# upload.sh [ino_file_path] [port]

INO_FULL_PATH="$1"
PORT="$2"

source /etc/ulysse314/arduino_script

if [[ "${INO_FULL_PATH}" = "" ]]; then
  INO_FULL_PATH="${MAIN_DIR}/boat/arduino/arduino.ino"
fi
if [[ "${PORT}" = "" ]]; then
  PORT=`${MAIN_DIR}/scripts/arduino/serial_ports.sh "239a_000b"`
fi

"${MAIN_DIR}/arduino/arduino-cli" --config-file "${ARDUINO_CLI_CONFIG}" upload "${INO_FULL_PATH}" --fqbn "${MAIN_BOARD_FQBN_PACKAGER}:${MAIN_BOARD_FQBN_ARCHITECTURE}:${MAIN_BOARD_FQBN_BOARD}" -p "${PORT}" --verify

RESULT=`echo $?`
if [[ "${RESULT}" == "0" ]]; then
  echo "=== Uploaded ==="
else
  echo "=== Failed ==="
fi

exit "${RESULT}"
