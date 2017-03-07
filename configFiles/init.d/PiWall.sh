#!/bin/bash
case $1 in
    start)
        echo "Starting PiWall."
        sudo /home/pi/PiWall /home/pi/public &
        ;;
    stop)
        echo "Stopping PiWall."
        sudo kill $(sudo lsof -t -i:8080)
        ;;
    *)
        echo "PiWall service."
        echo $"Usage $0 {start|stop}"
        exit 1
esac
exit 0
