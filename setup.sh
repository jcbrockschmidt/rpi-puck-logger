#!/usr/bin/env bash

# Make sure script is being run as sudo
if [[ $UID != 0 ]]
then
    echo "Please run this script as root"
    exit 1
fi

# Make sure an interface is specified
INTER=$1
if [ -z $INTER ]
then
    echo "Please specify an interface to capture packets from (e.g. eth0)"
    exit 1
fi

# Link to init script in /etc/init.d
DIR=$(dirname "$(readlink -f "$0")")
START="$DIR/start.sh"
INIT="/etc/init.d/rpi-puck-logger"
cat > $INIT << EOF
#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:		rpi-puck-logger
# Required-Start:	$remote_fs $syslog
# Required-Stop:	$remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Logs data from a Velodyne Puck LITE
# Description:		Logs data from a Velodyne Puck LITE
### END INIT INFO

$START $INTER
EOF
chmod 755 $INIT
