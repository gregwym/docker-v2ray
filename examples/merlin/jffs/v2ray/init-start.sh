#!/bin/sh

mkdir -p /tmp/var/logs/v2ray
cru a v2ray "*/1 * * * *" "/jffs/v2ray/watchdog.sh > /tmp/var/logs/v2ray/watchdog.log 2>&1"