#!/usr/bin/env python3

import os
import pprint
import shutil
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

def process_repository(command, repository_name, repositories, options):
  if repository_name == "--all":
    result = True
    for repository in repositories:
      if not process_repository(command, repository["name"], repositories, options):
        result = False
    return result
  repository = get_repository(repository_name, repositories)
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
      if "git-ssh" in options and options["git-ssh"]:
        git_url = "git@github.com:ulysse314/{}.git".format(repository["name"])
      else:
        git_url = "https://github.com/ulysse314/{}.git".format(repository["name"])
      result = subprocess.run([ "git", "clone", "--recurse-submodules", git_url ], cwd = path_dir)
      print("Install repository {} in {}, result {}".format(repository["name"], path_dir, result.returncode))
    returned_value = result.returncode == 0
  return returned_value

if len(sys.argv) < 3:
  print("Need command and repository name (or --all)")
  exit(-1)

command = sys.argv[1]
repository = sys.argv[2]
options = {}
if "--git-ssh" in sys.argv:
  options["git-ssh"] = True
process_repository(command, repository, repositories, options)
