#!/usr/bin/env python

# GPIO pin that controls LED
# 3.3V corresponds to LED on, and 0V to LED off
# Feel free to change this
PIN = 8

# Time elapse (in seconds) between on and off during blinking
# Feel free to change this
DELAY = 1


import sys

# Check arguments
if len(sys.argv) <= 1:
    print("Please provide an argument")
    print("Usage: {} on|off|blink".format(sys.argv[0]))
    sys.exit(1)

    
import RPi.GPIO as GPIO
import signal
import time

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(PIN, GPIO.OUT)

def cancelBlink():
    print("Cancelling LED blinking")
    GPIO.output(PIN, GPIO.LOW)
    GPIO.cleanup()

def catchTerm(signal, frame):
    # Called when SIGTERM is detected
    cancelBlink()
    sys.exit(0)

if sys.argv[1] == "on":
    print("Turning LED on")
    GPIO.output(PIN, GPIO.HIGH)

elif sys.argv[1] == "off":
    print("Turning LED off")
    GPIO.output(PIN, GPIO.LOW)
    GPIO.cleanup()

elif sys.argv[1] == "blink":
    print("Blinking LED")
    signal.signal(signal.SIGTERM, catchTerm)
    try:
        while True:
            GPIO.output(PIN, True)
            time.sleep(DELAY)
            GPIO.output(PIN, False)
            time.sleep(DELAY)
    except KeyboardInterrupt:
        cancelBlink()

else:
    print("Invalid argument: {}".format(sys.argv[1]))
