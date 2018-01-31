#!/usr/bin/env bash
# Parent directory
# DO NOT change this
DIR=$(dirname "$(readlink -f "$0")")


# Directory to dump collected data in
# Feel free to change this
DUMPDIR="$DIR/dump"


# Directory to put temporary files
# I mean, you could change this
# But why would you want to?
TMPDIR="/tmp/rpipucklogger"


# Make sure directories exist
mkdir -p $DUMPDIR
mkdir -p $TMPDIR

# Turns LED on
ledon () {
    $DIR/led.py on
}

# Turns LED off
ledoff () {
    $DIR/led.py off
}

# Stops LED blinking
TMPBLK="$TMPDIR/blink.pid"
stopblink () {
    # Kill blinking process if it exists
    if [[ -e $TMPBLK ]]
    then
	BLKPID=$(cat $TMPBLK)
	PINFO=$(ps -f -p $BLKPID)
	if [[ $PINFO == *"led.py"* ]]
	then
	    kill $BLKPID
	fi
    fi
}

# Starts LED blinking
blink () {
    stopblink
    $DIR/led.py blink &
    echo $! > $TMPBLK
}

# Cleanly terminates the program
exitscript () {
    echo "$(date): SIGINT or SIGTERM detected"
    trap - SIGINT SIGTERM
    if [ -z ${CHILD+x} ]
    then
	echo "$(date): Terminating data logging..."
	kill $CHILD
    fi
    stopblink
    ledoff
}
trap exitscript SIGINT SIGTERM


echo "$(date): Attempting to start logging..."

# Make sure script is being run as sudo
if [[ $UID != 0 ]]
then
    echo "Please run this script as root"
    blink
    exit 1
fi

# Make sure an interface is specified
INTER=$1
if [ -z $INTER ]
then
    echo "Please specify an interface to capture packets from (e.g. eth0)"
    blink
    exit 1
fi

# Make sure interface is up
ip l set $INTER up
if [ $? -ne 0 ]
then
    echo "$(date): Error with $INTER detected"
    blink
    exit 1
fi

# Test if interface is capturing packets
stopblink
ledoff
DATE=$(date +"%F_%k%M%S")
TEST="$TMPDIR/puck_$DATE.pcap"
timeout 5s tcpdump -i $INTER -w $TEST
NUMPACKS=$(tcpdump -r $TEST 2> /dev/null | wc -l)
rm -f $TEST &
if [ $NUMPACKS -lt 1 ]
then
    echo "$(date): No packets are being captured through $INTER"
    echo "$(date): Data logging cannot commence"
    blink
    sleep 0.5
    exit 1
fi

# Capture packets and write to $DUMP
DATE=$(date +"%F_%k%M%S")
DUMP="$DUMPDIR/$DATE.pcap"
echo "$(date): Recording packets from $INTER and writing to $DUMP"
ledon
tcpdump -w $DUMP -i $INTER &
CHILD=$!
wait $CHILD
stopblink
ledoff
