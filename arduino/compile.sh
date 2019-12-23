#!/bin/bash
# compile.sh [file_to_compile] [build_dir]

file_to_compile="$1"
build_dir="$2"

source /etc/ulysse314/script

if [[ "${file_to_compile}" = "" ]]; then
  file_to_compile="/home/ulysse314/boat/arduino/arduino.ino"
fi
source_dir=`dirname "${file_to_compile}"`
base_name=`basename "${file_to_compile}"`
if [[ "${build_dir}" = "" ]]; then
  build_dir="/tmp/arduino_build/${base_name}"
fi
mkdir -p "${build_dir}"
tmp_source_dir="/tmp/arduino_source/${base_name}"
mkdir -p "${tmp_source_dir}"
find "${source_dir}" -name "*.h" -exec cp '{}' "${tmp_source_dir}" \;
find "${source_dir}" -name "*.cpp" -exec cp '{}' "${tmp_source_dir}" \;
find "${source_dir}" -name "*.c" -exec cp '{}' "${tmp_source_dir}" \;
cp "${file_to_compile}" "${tmp_source_dir}"

/home/ulysse314/arduino/app/arduino-builder \
    -compile \
    -logger=machine \
    -hardware /home/ulysse314/arduino/app/hardware \
    -hardware /home/ulysse314/arduino/arduino15/packages \
    -libraries /home/ulysse314/arduino/libraries \
    -tools /home/ulysse314/arduino/app/tools-builder \
    -tools /home/ulysse314/arduino/app/hardware/tools/avr \
    -tools /home/ulysse314/arduino/arduino15/packages \
    -built-in-libraries /home/ulysse314/arduino/app/libraries \
    -fqbn=adafruit:samd:adafruit_feather_m0_express \
    -ide-version=10800 \
    -build-path "${build_dir}" \
    -warnings=all \
    -prefs=build.warn_data_percentage=75 \
    -prefs=runtime.tools.arm-none-eabi-gcc.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1 \
    -prefs=runtime.tools.openocd.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/openocd/0.9.0-arduino \
    -prefs=runtime.tools.bossac.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/bossac/1.6.1-arduino \
    -prefs=runtime.tools.CMSIS.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/CMSIS/4.0.0-atmel \
    -prefs="compiler.cpp.extra_flags=-DBOAT_ID=${BOAT_ID}" \
    -verbose \
    "${tmp_source_dir}/${base_name}"
result=`echo $?`
if [[ "${result}" == "0" ]]; then
  echo "=== Compiled ==="
else
  echo "=== Failed ==="
fi
exit "${result}"
