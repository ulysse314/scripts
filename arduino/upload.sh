#!/bin/bash

port="$1"

/home/ulysse314/arduino/arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d "--port=${port}" -U true -i -e -w -v /tmp/arduino_build/arduino.ino.bin -R
exit $?