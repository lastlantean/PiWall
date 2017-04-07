#!/bin/bash

### BEGIN INIT INFO
# Provides:		PiWall
# Required-Start:
# Required-Stop:
# Should-Start:		$network
# Should-Stop:
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:    PiWall
# Description:		PiWall
### END INIT INFO

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
