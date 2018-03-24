#!/bin/bash

port=`/home/ulysse314/scripts/arduino/serial_ports.sh`
mkdir -p /tmp/arduino_build
/home/ulysse314/arduino/app/arduino-builder -compile -logger=machine -hardware /home/ulysse314/arduino/app/hardware -hardware /home/ulysse314/arduino/arduino15/packages -tools /home/ulysse314/arduino/app/tools-builder -tools /home/ulysse314/arduino/app/hardware/tools/avr -tools /home/ulysse314/arduino/arduino15/packages -built-in-libraries /home/ulysse314/arduino/app/libraries -fqbn=adafruit:samd:adafruit_feather_m0_express -ide-version=10800 -build-path /tmp/arduino_build -warnings=none -prefs=build.warn_data_percentage=75 -prefs=runtime.tools.arm-none-eabi-gcc.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1 -prefs=runtime.tools.openocd.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/openocd/0.9.0-arduino -prefs=runtime.tools.bossac.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/bossac/1.6.1-arduino -prefs=runtime.tools.CMSIS.path=/home/ulysse314/arduino/arduino15/packages/arduino/tools/CMSIS/4.0.0-atmel -verbose /home/ulysse314/boat/arduino/arduino.ino
if [ "$?" != 0 ]; then
  exit 1
fi
/home/ulysse314/scripts/arduino/reset.py "${port}"
if [ "$?" != 0 ]; then
  exit 2
fi
sleep 2
/home/ulysse314/arduino/arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d "--port=${port}" -U true -i -e -w -v /tmp/arduino_build/arduino.ino.bin -R
if [ "$?" != 0 ]; then
  exit 3
fi
