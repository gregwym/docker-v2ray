#!/bin/sh

DAEMON_DIR=/mnt/sda1/v2ray
DAEMON=$DAEMON_DIR/current/v2ray
DAEMON_PARAMS="-config $DAEMON_DIR/config.json"
NAME=v2ray
PID_DIR=/var/run/v2ray
PID_FILE=$PID_DIR/v2ray.pid
LOG_DIR=/tmp/var/logs/v2ray
LOG_OUT=$LOG_DIR/stdout.log
LOG_ERR=$LOG_DIR/stderr.log

test -x $DAEMON || exit 255

setupIptables() {
  echo "Setting up NAT rules"
  iptables -t nat -N V2RAY || iptables -t nat -F V2RAY # 新建或清空 V2RAY 的链
  iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN
  iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN
  iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN
  iptables -t nat -A V2RAY -d 172.16.0.0/12 -j RETURN
  iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN
  iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN
  iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN
  iptables -t nat -A V2RAY -p tcp -j RETURN -m mark --mark 0xff # 直连 SO_MARK 为 0xff 的流量(0xff 是 16 进制数，数值上等同与上面配置的 255)，此规则目的是避免代理本机(网关)流量出现回环问题
  iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 3455   # 其余流量转发到 3455 端口（即 V2Ray）
  iptables -t nat -A PREROUTING -p tcp -j V2RAY                 # 对局域网其他设备进行透明代理
  # iptables -t nat -A OUTPUT -p tcp -j V2RAY                     # 对本机进行透明代理
  echo "NAT rules are up"
}

flushIptables() {
  echo "Deleting NAT rules"
  # iptables -t nat -D OUTPUT -p tcp -j V2RAY
  iptables -t nat -D PREROUTING -p tcp -j V2RAY
  iptables -t nat -F V2RAY
  iptables -t nat -X V2RAY
  echo "NAT rules deleted"
}

start() {
  if [ ! -d $PID_DIR ]; then
    mkdir -p $PID_DIR
  fi

  if [ ! -d $LOG_DIR ]; then
    mkdir -p $LOG_DIR
  fi

  echo "Starting $NAME"
  daemonize -p $PID_FILE -l $PID_FILE -o $LOG_OUT -e $LOG_ERR $DAEMON $DAEMON_PARAMS
  if [ $? != 0 ]; then
    echo "Failed to start $NAME"
    exit 1
  fi
  echo "$NAME started"
  setupIptables
}

stop() {
  flushIptables
  echo "Stopping $NAME"
  kill $(cat $PID_FILE)
  rm -f $PID_FILE
  echo "$NAME stopped"
}

status() {
  if ! iptables -t nat -C PREROUTING -p tcp -j V2RAY; then
    echo "iptables rule does not exists"
    exit 3
  fi

  if [ ! -f $PID_FILE ]; then
    echo "$NAME is stopped"
    exit 1
  fi

  PID=$(cat $PID_FILE)
  if [ ! -n "$PID" -o ! -e /proc/$PID ]; then
    echo "$NAME is stopped"
    exit 2
  fi

  echo "$NAME is running, pid: $PID"
}

case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
restart)
  stop
  start
  ;;
status)
  status
  ;;
*)
  echo "Usage: (start|stop|restart|status)"
  exit 255
  ;;
esac
