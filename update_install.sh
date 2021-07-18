#!/bin/bash
# update_install.sh

set -x

update_git() {
  REPOSITORY="$1"
  GIT_PATH="$2"
  URL="https://github.com/ulysse314/${REPOSITORY}.git"
  pushd .
  cd "${GIT_PATH}"
  if [[ ! -d "${GIT_PATH}/${REPOSITORY}" ]]; then
    git clone "${URL}"
  else
    cd "${REPOSITORY}"
    git pull --rebase
  fi
  popd
}

update_dir() {
  DIR_PATH=`dirname $1`
  rsync -aqv --delete-after -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:$1" "${MAIN_DIR}/${DIR_PATH}/"
  chown -R ulysse314:ulysse314 "${MAIN_DIR}/${DIR_PATH}/"
}

source /etc/ulysse314/script

if [[ $EUID != 0 ]]; then
    echo "Please run as root"
    exit -1
fi

ssh -p "${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}" "/usr/bin/env true"
if [[ "$?" != "0" ]]; then
  echo "Can't connect to backup server"
  cat ~/.ssh/id_rsa.pub
  exit -1
fi

echo "Ulysse314 update"
date
cp "${MAIN_DIR}/scripts/linux/authorized_keys" "/root/.ssh/authorized_keys"
cp "${MAIN_DIR}/scripts/linux/authorized_keys" "${MAIN_DIR}/.ssh/authorized_keys"
chown ulysse314:ulysse314 "${MAIN_DIR}/.ssh/authorized_keys"
scp -P "${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:known_hosts" /root/.ssh/known_hosts
rsync -aqv --delete-after --exclude "name" -e "ssh -p ${BACKUP_PORT}" "${BACKUP_USER}@${BACKUP_SERVER}:ulysse314" "/etc/"

source /etc/ulysse314/arduino_script

echo "Apt update"
date
apt update
apt upgrade -y
apt autoremove -y
apt install -y emacs-nox python3 autossh screen git python3-aiohttp python3-xmltodict gpsd python3-psutil python3-pip nginx libfl2 rsync ifmetric

echo "Pip update"
date
pip3 install pyserial-asyncio
pip3 install adafruit-pca9685
pip3 install netifaces

echo "Source update"
date

# Arduino dirs
if [[ ! -z "${ARDUINO_DIR}" ]]; then
  mkdir -p "${ARDUINO_DIR}"
  mkdir -p "${ARDUINO_DATA_DIR}"
  mkdir -p "${ARDUINO_USER_DIR}"
  mkdir -p "${ARDUINO_LIBRARY_DIR}"
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR="${ARDUINO_DIR}" sh
  "${ARDUINO_DIR}/arduino-cli" config init --additional-urls https://adafruit.github.io/arduino-board-index/package_adafruit_index.json --dest-dir "${ARDUINO_DATA_DIR}"
  rm -fr ~/.arduino15
  sed -i 's@/root/.arduino15@'"${ARDUINO_DATA_DIR}"'@g' "${ARDUINO_CLI_CONFIG}"
  sed -i 's@/root/Arduino@'"${ARDUINO_USER_DIR}"'@g' "${ARDUINO_CLI_CONFIG}"
  "${ARDUINO_DIR}/arduino-cli" --config-file "${ARDUINO_CLI_CONFIG}" core install adafruit:samd

  # Arduino git
  update_git Arduino-MemoryFree "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoADS1X15 "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoBME680 "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoBNO055 "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoBusDevice "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoINA219 "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoMTK3339 "${ARDUINO_LIBRARY_DIR}"
  update_git ArduinoPCA9685 "${ARDUINO_LIBRARY_DIR}"
  update_git OneWire "${ARDUINO_LIBRARY_DIR}"
  update_git SleepyDog "${ARDUINO_LIBRARY_DIR}"

  update_git ArduinoPlayground "${ARDUINO_DIR}"
fi

# Ulysse git
update_git boat "${MAIN_DIR}"
update_git scripts "${MAIN_DIR}"

echo "Linux update"
date
if [ -f "${MAIN_DIR}/scripts/linux/crontab" ]; then
  cat /etc/crontab | grep -v ULYSSE314 > /tmp/crontab
  cat "${MAIN_DIR}/scripts/linux/crontab" >> /tmp/crontab
  mv /tmp/crontab /etc/crontab
fi
if [ -f "${MAIN_DIR}/scripts/linux/dhcpcd.conf" ]; then
  cat /etc/dhcpcd.conf | grep -v ULYSSE314 > /tmp/dhcpcd.conf
  cat "${MAIN_DIR}/scripts/linux/dhcpcd.conf" >> /tmp/dhcpcd.conf
  mv /tmp/dhcpcd.conf /etc/dhcpcd.conf
fi
if [ ! -f /var/www/html/munin ]; then
  ln -s /var/cache/munin/www /var/www/html/munin
fi
if [ ! -e /etc/munin/plugins/ulysse314.py ]; then
  ln -s "${MAIN_DIR}/scripts/linux/munin_plugin.py" /etc/munin/plugins/ulysse314.py
fi
if [ ! -f /etc/udev/rules.d/99-feather-symlink.rules ]; then
  ln -s "${MAIN_DIR}/scripts/linux/udev-rules" /etc/udev/rules.d/99-feather-symlink.rules
fi

# Camera
CAMERA_ENABLED="0"
if [[ "${CAMERA_ENABLED}" == "1" ]]; then
  echo "camera update"
  date
  grep uv4l /etc/apt/sources.list | grep stretch
  if [[ "$?" != "0" ]]; then
    curl http://www.linux-projects.org/listing/uv4l_repo/lpkey.asc | sudo apt-key add -
    cat /etc/apt/sources.list | grep -v uv4l > /tmp/sources.list
    cat /tmp/sources.list > /etc/apt/sources.list
    echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/stretch stretch main" >> /etc/apt/sources.list
    apt update
  fi
  grep start_x /boot/config.txt
  if [[ "$?" != "0" ]]; then
    echo "start_x=1" >> /boot/config.txt
  else
    sed -i "s/start_x=0/start_x=1/g" /boot/config.txt
  fi
  grep gpu_mem /boot/config.txt
  if [[ "$?" != "0" ]]; then
    echo "gpu_mem=128" >> /boot/config.txt
  fi
  apt install -y uv4l uv4l-raspicam uv4l-raspicam-extras uv4l-server uv4l-uvc uv4l-xscreen uv4l-mjpegstream uv4l-dummy uv4l-raspidisp uv4l-tc358743-extras
fi

echo "done"
date
date > /tmp/last_update_install.txt
