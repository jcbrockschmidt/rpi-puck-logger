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

# Make sure log file directory is specified
if [ -z $2 ]
then
    echo "Please specify a directory to store log files in"
    exit 1
fi
LOGDIR=$(readlink -f "$2")

# Link to init script in /etc/init.d
DIR=$(dirname "$(readlink -f "$0")")
START="$DIR/start.sh"
SCRIPT="rpi-puck-logger"
INIT="/etc/init.d/$SCRIPT"
# TODO: add $time to Required-Start one RTC is integrated
cat > $INIT << EOF
#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:		rpi-puck-logger
# Required-Start:	\$remote_fs \$syslog \$network
# Required-Stop:	\$remote_fs \$syslog \$network
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Logs data from a Velodyne Puck LITE
# Description:		Logs data from a Velodyne Puck LITE
### END INIT INFO

case \$1 in
  start)
    DATE=\$(date +"%F_%k%M%S")
    $START $INTER > $LOGDIR/\$DATE.log 2>&1 &
    ;;
  *)
    echo "Usage: $INIT start"
    ;;
esac

exit 0
EOF
chmod 755 $INIT
update-rc.d $SCRIPT defaults
