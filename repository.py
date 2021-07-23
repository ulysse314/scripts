#!/usr/bin/env python3

import os
import pprint
import shutil
import subprocess
import sys

if "/etc/ulysse314" not in sys.path:
  sys.path.append("/etc/ulysse314")

import locations

class Repository:
  def __init__(self, name, location, forked_from):
    self.name = name
    self.location = location
    self.forked_from = forked_from

  def get_name(self):
    return self.name

  def get_path(self):
    return locations.get_path_location(self.location)

  def get_forked_from(self):
    return self.forked_from

HTTP_URL_TYPE = "http"
SSH_URL_TYPE = "git"
URL_PER_TYPE = {
  SSH_URL_TYPE: "git@github.com:ulysse314/{}.git",
  HTTP_URL_TYPE: "https://github.com/ulysse314/{}.git",
}

repositories = [
  Repository("Arduino-MemoryFree", "arduino_library_dir", "https://github.com/mpflaga/Arduino-MemoryFree.git"),
  Repository("ArduinoADS1X15", "arduino_library_dir", "https://github.com/adafruit/Adafruit_ADS1X15.git"),
  Repository("ArduinoBME680", "arduino_library_dir", "https://github.com/adafruit/Adafruit_BME680.git"),
  Repository("ArduinoBNO055", "arduino_library_dir", "https://github.com/adafruit/Adafruit_BNO055.git"),
  Repository("ArduinoBusDevice", "arduino_library_dir", None),
  Repository("ArduinoINA219", "arduino_library_dir", "https://github.com/flav1972/ArduinoINA219.git"),
  Repository("ArduinoMTK3339", "arduino_library_dir", "https://github.com/adafruit/Adafruit_GPS.git"),
  Repository("ArduinoPCA9685", "arduino_library_dir", "https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library.git"),
  Repository("OneWire", "arduino_library_dir", None),
  Repository("SleepyDog", "arduino_library_dir", "https://github.com/adafruit/Adafruit_SleepyDog.git"),
  Repository("ArduinoPlayground", "arduino_dir", None),
  Repository("mavlink", "main_dir", "https://github.com/mavlink/mavlink.git"),
  Repository("boat", "main_dir", None),
  Repository("scripts", "main_dir", None)
]

def get_repository(name, repositories):
  for repository in repositories:
    if name == repository.get_name():
      return repository
  return None

def get_remote_url(repository, type):
  git_url = URL_PER_TYPE[type]
  return git_url.format(repository.get_name())

def process_repository(command, repository_name, repositories, options):
  if repository_name == "--all":
    result = True
    for repository in repositories:
      if not process_repository(command, repository.get_name(), repositories, options):
        result = False
    return result
  repository = get_repository(repository_name, repositories)
  if repository is None:
    print("{} is unknown".format(repository_name))
    return False
  path_dir = repository.get_path()
  repository_path_dir = os.path.join(path_dir, repository_name)
  if command == "delete":
    returned_value = True
    if os.path.exists(repository_path_dir):
      try:
        shutil.rmtree(repository_path_dir)
        print("Delete {} in {}".format(repository.get_name(), path_dir))
      except:
        returned_value = False
    else:
      print("Doesn't exist {} in {}".format(repository.get_name(), path_dir))
  elif command == "update":
    if os.path.exists(repository_path_dir):
      result = subprocess.run([ "git", "pull", "--rebase" ], cwd = repository_path_dir)
      if result.returncode == 0:
        result = subprocess.run([ "git", "submodule", "update", "--init"], cwd = repository_path_dir)
      print("Update repository {} in {}, result {}".format(repository.get_name(), path_dir, result.returncode))
    else:
      git_url = get_remote_url(repository, options["url-type"])
      result = subprocess.run([ "git", "clone", "--recurse-submodules", git_url ], cwd = path_dir)
      if repository.get_forked_from() is not None and result.returncode == 0:
        result = subprocess.run([ "git", "remote", "add", "upstream", repository.get_forked_from() ], cwd = repository_path_dir)
      print("Install repository {} in {}, result {}".format(repository.get_name(), path_dir, result.returncode))
    returned_value = result.returncode == 0
  elif command == "sshurl":
    origin_url = get_remote_url(repository, SSH_URL_TYPE)
    result = subprocess.run([ "git", "remote", "set-url", "origin",  origin_url], cwd = repository_path_dir)
    print("Update repository {} to origin {}, result {}".format(repository.get_name(), origin_url, result.returncode))
    returned_value = result.returncode == 0
  elif command == "info":
    print("{} location: {}".format(repository.get_name(), repository.get_path()))
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

