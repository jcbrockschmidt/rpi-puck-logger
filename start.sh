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

# Make sure interface is up
ip l set $INTER up
if [ $? -ne 0 ]
then
	echo "Error with $INTER detected"
	exit 1
fi

# Test if interface is capturing packets
DATE=$(date +"%F_%k%M%S")
TMP="/tmp/puck_$DATE.pcap"
timeout 5s tcpdump -i $INTER -w $TMP
NUMPACKS=$(tcpdump -r $TMP 2> /dev/null | wc -l)
rm -f $TMP
if [ $NUMPACKS -lt 1 ]
then
	echo "No packets are being captured through $INTER"
	# TODO: blink LED until poweroff
	exit 1
fi

# Capture packets and write to $DUMP
DIR=$(dirname "$(readlink -f "$0")")
DUMP="$DIR/$DATE.pcap"
echo "Recording packets from $INTER and writing to $DUMP"
tcpdump -w $DUMP -i $INTER # TODO: turn LED on
