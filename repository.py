#!/usr/bin/env python3

import os
import pprint
import shutil
import subprocess
import sys

if "/etc/ulysse314" not in sys.path:
  sys.path.append("/etc/ulysse314")

import locations

HTTP_URL_TYPE = "http"
SSH_URL_TYPE = "git"
URL_PER_TYPE = {
  SSH_URL_TYPE: "git@github.com:ulysse314/{}.git",
  HTTP_URL_TYPE: "https://github.com/ulysse314/{}.git",
}

repositories = [
  {
    "name": "Arduino-MemoryFree",
    "location": "arduino_library_dir",
    "from": "https://github.com/mpflaga/Arduino-MemoryFree.git",
  },
  {
    "name": "ArduinoADS1X15",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit_ADS1X15.git",
  },
  {
    "name": "ArduinoBME680",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit_BME680.git",
  },
  {
    "name": "ArduinoBNO055",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit_BNO055.git",
  },
  {
    "name": "ArduinoBusDevice",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoINA219",
    "location": "arduino_library_dir",
    "from": "https://github.com/flav1972/ArduinoINA219.git",
  },
  {
    "name": "ArduinoMTK3339",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit_GPS.git",
  },
  {
    "name": "ArduinoPCA9685",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library.git",
  },
  {
    "name": "OneWire",
    "location": "arduino_library_dir",
  },
  {
    "name": "SleepyDog",
    "location": "arduino_library_dir",
    "from": "https://github.com/adafruit/Adafruit_SleepyDog.git",
  },
  {
    "name": "ArduinoPlayground",
    "location": "arduino_dir",
  },
  {
    "name": "mavlink",
    "location": "main_dir",
    "from": "https://github.com/mavlink/mavlink.git",
  },
  {
    "name": "boat",
    "location": "main_dir",
  },
  {
    "name": "scripts",
    "location": "main_dir",
  },
]

def get_repository(name, repositories):
  for repository in repositories:
    if name == repository["name"]:
      return repository
  return None

def get_remote_url(repository, type):
  git_url = URL_PER_TYPE[type]
  return git_url.format(repository["name"])

def process_repository(command, repository_name, repositories, options):
  if repository_name == "--all":
    result = True
    for repository in repositories:
      if not process_repository(command, repository["name"], repositories, options):
        result = False
    return result
  repository = get_repository(repository_name, repositories)
  if repository is None:
    print("{} is unknown".format(repository_name))
    return False
  path_dir = locations.get_path_location(repository["location"])
  repository_path_dir = os.path.join(path_dir, repository_name)
  if command == "delete":
    returned_value = True
    if os.path.exists(repository_path_dir):
      try:
        shutil.rmtree(repository_path_dir)
        print("Delete {} in {}".format(repository["name"], path_dir))
      except:
        returned_value = False
    else:
      print("Doesn't exist {} in {}".format(repository["name"], path_dir))
  elif command == "update":
    if os.path.exists(repository_path_dir):
      result = subprocess.run([ "git", "pull", "--rebase" ], cwd = repository_path_dir)
      if result.returncode == 0:
        result = subprocess.run([ "git", "submodule", "update", "--init"], cwd = repository_path_dir)
      print("Update repository {} in {}, result {}".format(repository["name"], path_dir, result.returncode))
    else:
      git_url = get_remote_url(repository, options["url-type"])
      result = subprocess.run([ "git", "clone", "--recurse-submodules", git_url ], cwd = path_dir)
      if "from" in repository and result.returncode == 0:
        result = subprocess.run([ "git", "remote", "add", "upstream", repository["from"] ], cwd = repository_path_dir)
      print("Install repository {} in {}, result {}".format(repository["name"], path_dir, result.returncode))
    returned_value = result.returncode == 0
  elif command == "info":
    print("{} location: {}".format(repository["name"], locations.get_path_location(repository["location"])))
    for url_type in URL_PER_TYPE:
      print("  + {}".format(get_remote_url(repository, url_type)))
    returned_value = True
  return returned_value

if len(sys.argv) < 3:
  print("{} <delete | update | info> <repository_name | --all> [--git-ssh]".format(sys.argv[0]))
  exit(-1)

command = sys.argv[1]
repository = sys.argv[2]
options = {
  "url-type": SSH_URL_TYPE if "--git-ssh" in sys.argv else HTTP_URL_TYPE,
}
result = process_repository(command, repository, repositories, options)
exit(0 if result else -1)

