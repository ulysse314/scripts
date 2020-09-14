#!/bin/bash
# compile.sh [ino_file_path]

INO_FULL_PATH="$1"

source /etc/ulysse314/arduino_script

if [[ "${INO_FULL_PATH}" = "" ]]; then
  INO_FULL_PATH="${MAIN_DIR}/boat/arduino/arduino.ino"
fi

"${MAIN_DIR}/arduino/arduino-cli" --config-file "${ARDUINO_CLI_CONFIG}" compile "${INO_FULL_PATH}" --libraries "${ARDUINO_DIR}/libraries" --fqbn "${MAIN_BOARD_FQBN_PACKAGER}:${MAIN_BOARD_FQBN_ARCHITECTURE}:${MAIN_BOARD_FQBN_BOARD}" --build-properties "compiler.cpp.extra_flags=-DBOAT_ID=${BOAT_ID}" --warnings all

RESULT=`echo $?`
if [[ "${RESULT}" == "0" ]]; then
  echo "=== Compiled ==="
else
  echo "=== Failed ==="
fi

exit "${RESULT}"
