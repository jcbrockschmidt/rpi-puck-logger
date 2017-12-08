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

# Starts LED blinking
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
blink () {
    stopblink
    $DIR/led.py blink &
    echo $! > $TMPBLK
}

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
    echo "Error with $INTER detected"
    blink
    exit 1
fi

# Test if interface is capturing packets
stopblink
DATE=$(date +"%F_%k%M%S")
TEST="$TMPDIR/puck_$DATE.pcap"
timeout 5s tcpdump -i $INTER -w $TEST
NUMPACKS=$(tcpdump -r $TEST 2> /dev/null | wc -l)
rm -f $TEST
if [ $NUMPACKS -lt 1 ]
then
    echo "No packets are being captured through $INTER"
    blink
    exit 1
fi

# Capture packets and write to $DUMP
DUMP="$DUMPDIR/$DATE.pcap"
echo "Recording packets from $INTER and writing to $DUMP"
$DIR/led.py on
tcpdump -w $DUMP -i $INTER
