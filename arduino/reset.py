#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# reset_arduino.py [serial_port]

import pprint
import serial
import sys
import traceback

def default_port():
  return '/dev/ttyACM0'

def reset_arduino_on_port(port = None):
  port = default_port() if port == None else port
  with serial.Serial(port, 1200) as ser:
    ser.setDTR(False)

def main(args):
  r = 0
  try:
    reset_arduino_on_port(args[1] if len(args) > 1 else None)
  except:
    sys.stderr.write('Exception caught in main()\n')
    traceback.print_exc()
    r = 1
  return r

if __name__ == '__main__':
  sys.exit(main(sys.argv))
