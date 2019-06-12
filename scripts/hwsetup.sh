#!/bin/sh
### BEGIN INIT INFO
# Provides:		hwsetup
# Required-Start:	ti81xx-firmware
# Required-Stop:	ti81xx-firmware
# Default-Start:	S
# Default-Stop:		0 6
# Short-Description:	Setup Chronos Hardware
# Description:		Setup Chronos Hardware
### END INIT INFO

case "$1" in
	start)
		;;
	stop)
		exit 0
		;;
	*)
		echo "Usage: $0 {start|stop}"
		exit 1
        	;;
esac

#################################################
## Initialize the video display devices.
#################################################
modprobe vpss sbufaddr=0xBFB00000 mode=dvo2:800x480@60 i2c_mode=0
modprobe ti81xxfb vram=0:24M,1:16M,2:6M
modprobe ti81xxhdmi

echo "Configuring LCD on /dev/fb0"
echo 0 > /sys/devices/platform/vpss/display1/enabled
echo 33500,800/204/49/20,480/10/23/10,1 > /sys/devices/platform/vpss/display1/timings
echo triplediscrete,rgb888,0/0/0/0 > /sys/devices/platform/vpss/display1/output
echo 1,2/3/1/0 > /sys/devices/platform/vpss/display1/order
echo 1 > /sys/devices/platform/vpss/display1/enabled
echo 1:dvo2 > /sys/devices/platform/vpss/graphics0/nodes

TIMEOUT=10	
until [ -e /dev/fb0 ] || [ "$TIMEOUT" -eq "0" ]; 
do
	TIMEOUT=$((TIMEOUT-1))
	sleep 0.5
done
if [ -e /dev/fb0 ]; then
	fbset -xres 800 -yres 480 -vxres 800 -vyres 1440
fi

#################################################
## Initialize the FPGA control signals.
#################################################
#PROGRAMn
echo 47 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio47/direction
echo 1 > /sys/class/gpio/gpio47/value
#INITn
echo 45 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio45/direction
#DONE
echo 52 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio52/direction
#SN
echo 58 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio58/direction
echo 1 > /sys/class/gpio/gpio58/value
#HOLDn
echo 53 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio53/direction
echo 1 > /sys/class/gpio/gpio53/value

#################################################
## Setup the Encoder Wheel Inputs
#################################################
#ENCA
echo 20 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio20/direction
echo both > /sys/class/gpio/gpio20/edge
#ENCB
echo 26 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio26/direction
echo both > /sys/class/gpio/gpio26/edge
#ENCSW
echo 27 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio27/direction
echo both > /sys/class/gpio/gpio27/edge

#################################################
## Setup the Trigger IO Input pins.
#################################################
#IO1
echo 21 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio21/direction
#IO2
echo 127 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio127/direction
#IsoIn1
echo 16 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio16/direction

#################################################
## Setup recording status signals.
#################################################
#Shutter Button
echo 66 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio66/direction
#Record LED Back
echo 25 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio25/direction
echo 0 > /sys/class/gpio/gpio25/value
#Record LED Front
echo 41 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio41/direction
echo 0 > /sys/class/gpio/gpio41/value
#GPIO2/Frame End
echo 51 > /sys/class/gpio/export
echo rising > /sys/class/gpio/gpio51/edge

#################################################
## Setup miscellaneous control signals.
#################################################
#ColorSel
echo 34 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio34/direction
#SPI_DAC_CS_n
echo 33 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio33/direction
echo 1 > /sys/class/gpio/gpio33/value
#FPGASoftReset
echo 54 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio54/direction
echo 0 > /sys/class/gpio/gpio54/value

exit 0
