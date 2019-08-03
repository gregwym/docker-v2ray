#!/bin/sh

# print current date
date

# change working dir to where the script is
cd "$(dirname "$0")"

# check v2ray status
./init.d.sh status
V2RAY_STATUS=$?

# restart if necessary
case $V2RAY_STATUS in
0)
echo "v2ray is up"
;;
255)
echo "v2ray not found"
;;
*)
  echo "v2ray is down, restarting"
  ./init.d.sh restart
  echo "v2ray restarted"
esac
