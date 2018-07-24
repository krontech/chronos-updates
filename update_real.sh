#! /bin/sh
# Script to perform software update for Chronos 1.4 camera
#
# Authors: David Kronstein, Kron Technologies Inc.
#          Matthew Peters, Kron Technologies Inc.
#

echo "Stopping camApp"
killall camApp

bitmap=/media/sda1/camUpdate/busy.raw
if [ -f $bitmap ]; then
	while true; do
		ps_out=$(ps)
		grep_out=$(echo $ps_out | grep camApp)
		if [[ "$grep_out" == "" ]]; then
			break
		else
			sleep 0.1s
		fi
	done
	echo "---<<< Showing Shutdown Splash >>>---"
	sleep 0.5s
	cat $bitmap > /dev/fb0
fi


echo "deleting old /boot directory"
rm -rf /boot/*

echo "copying new files into place"
cd /

# just in case it didn't draw before
if [ -f $bitmap ]; then
	cat $bitmap > /dev/fb0
fi

# copy new files into place
tar zxvf /media/sda1/camUpdate/update.tgz

echo "get rid of old TI logo"
[ -e /media/mmcblk0p1/ti_logo.bmp ] && echo "removing ti logo" && rm /media/mmcblk0p1/ti_logo.bmp

echo "copy in the new boot components"
cp /boot/* /media/mmcblk0p1/

echo "fixing init script links"

update-rc.d -f telnetd remove
update-rc.d -f thttpd remove
update-rc.d -f banner remove
update-rc.d -f psplash remove
update-rc.d -f shutdown_splash.sh remove
update-rc.d -f matrix-gui-e remove
# this one never worked and even if it did would only show on the serial terminal
update-rc.d -f gplv3-notice remove

update-rc.d -f udev remove
update-rc.d udev start 3 S .

update-rc.d -f load-hd-firmware.sh remove
update-rc.d load-hd-firmware.sh start 40 S .

update-rc.d -f vidorder remove
update-rc.d vidorder start 41 S .

update-rc.d -f camera remove
update-rc.d camera start 42 S . stop 0 0 6 .

update-rc.d -f networking remove
update-rc.d networking start 60 S .

update-rc.d -f mountnfs.sh remove
update-rc.d mountnfs.sh start 65 S .

update-rc.d -f bootmisc.sh remove
update-rc.d bootmisc.sh start 70 S .

update-rc.d -f alsa-state remove
update-rc.d alsa-state start 80 S .

update-rc.d udhcpcd defaults


echo "completed!"

#exit 0
reboot
