#!/bin/bash
choice=$1
case $choice in
  start)
    echo "Start app"
  ;;
  stop)
    echo "Stop app"
  ;;
  force-reload|restart)
    echo "Restart app"
  ;;
  *)
    echo "Usage: $0 (start|stop|force-reload|restart)"
    exit 3
  ;;
esac