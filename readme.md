## Raspberry Pi Velodyne Puck LITE Logger

# Description

Logs packet data collected from a Velodyne Puck LITE

# Setup

 * Install an operating system for your Raspberry Pi
   - I recommend Rasbian LITE or some other Debian variant
   - You will likely want to format the partition that you will be storing your collected data on to FAT32 so data can be easily retrieved from Windows and OS X
 * Establish and internet connection and install the necessary packages with
    ```
    sudo apt install python3-dev python3-rpi.gpio git
    ```
 * Clone the rpi-puck-logger repository
   - I recommend just putting it in your home directory
    ```
    cd ~
    git clone https://github.com/joshuabrockschmidt/rpi-puck-logger.git
    ```
 * *Optional*: Set directory for dumping data
   - By default, the directory for dumping data is "dump" inside the parent directory
   - This can be changed by changing ```$DUMPDIR``` in ```start.sh``` near the top of the file to your desired dump directory
 * Setup auto-logging
   - Run ```setup.sh``` with the name of the interface data will be streamed to and the directory to write logs to. For example, if your interface is ```eth0``` and you want to write logs to ```~/logs/```, run
    ```
    sudo ./setup.sh eth0 ~/logs/
    ```
   - This will make ```start.sh``` run on bootup
   - Data files will timestamped and placed in your dump directory
 * Manual logging
   - If you want to start data logging manually, simply run ```start.sh``` with the name of the interface data is being streamed to. For example, if your interface is ```eth0```, run
    ```
    sudo ./start.sh eth0
    ```
   - A timestamped file will be created in your dump directory
 * *Optional*: LED status indicator
   - You can attach an LED circuit to a GPIO pin to receive feedback about logging status
     * The LED will turn on when logging has started
     * The LED will blink when something has gone wrong and logging has no commenced
   - The GPIO pin is 8 by default. This can be changed by changing the variable ```PIN``` at the top of ```led.py```.
     * Note that 3.3V is LED on and 0V is LED off. Design your circuit accordingly
 * *Optional*: Button interrupt
   - You can attach a push button to a GPIO pin which will terminate data recording when pressed
   - The GPIO pin is GPIO 18 by default. This can be changed by changing the variable ```PIN``` at the top of ```waitbutton.py```.
