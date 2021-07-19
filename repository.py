#!/usr/bin/env python3

import subprocess
import sys

if "/etc/ulysse314" not in sys.path:
  sys.path.append("/etc/ulysse314")

import locations

repositories = [
  {
    "name": "Arduino-MemoryFree",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoADS1X15",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoBME680",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoBNO055",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoBusDevice",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoINA219",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoMTK3339",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoPCA9685",
    "location": "arduino_library_dir",
  },
  {
    "name": "OneWire",
    "location": "arduino_library_dir",
  },
  {
    "name": "SleepyDog",
    "location": "arduino_library_dir",
  },
  {
    "name": "ArduinoPlayground",
    "location": "arduino_dir",
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

def install_repository(repository, repositories):
  if repository == "--all":
    for repository in repositories:
      install_repository(repository, repositories)
    return
  path_dir = locations.get_path_location(repository["location"])
  result = subprocess.run([ "git", "clone", "--recurse-submodules", "https://github.com/ulysse314/{}.git".format(repository["name"]) ], cwd = path_dir)
  print("Install repository {} in {}, result {}".format(repository["name"], path_dir, result.returncode))
  return result.returncode == 0

def update_repository(repository, repositories):
  if repository == "--all":
    for repository in repositories:
      update_repository(repository, repositories)
    return
  path_dir = locations.get_path_location(repository["location"])
  result = subprocess.run([ "git", "pull", "--rebase" ], cwd = path_dir)
  if result.returncode == 0:
    result = subprocess.run([ "git", "submodule", "update", "--init"], cwd = path_dir)
  print("Update repository {} in {}, result {}".format(repository["name"], path_dir, result.returncode))
  return result.returncode == 0

if len(sys.argv) != 3:
  print("Need command and repository name (or --all)")
  exit(-1)

command = sys.argv[1]
repository = sys.argv[2]
if command == "install":
  install_repository(repository, repositories)
elif command == "update":
  update_repository(repository, repositories)
