#!/bin/sh

start_process=`ps auxww | grep "/home/ulysse314/boat/start.sh" | grep "bash"`
if [ "$?" = "0" ]; then
  process_id=`echo "${start_process}" | awk '{ print $2 }'`
  echo "start process ${process_id}"
  kill -9 "${process_id}"
fi
server_process=`ps auxww | grep "/home/ulysse314/boat/boat/server.py" | grep "python"`
if [ "${?}" = "0" ]; then
  process_id=`echo "${server_process}" | awk '{ print $2 }'`
  echo "server process ${process_id}"
  kill -9 "${process_id}"
fi
echo "/home/ulysse314/boat/boat/server.py"
