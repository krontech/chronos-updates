#!/bin/busybox ash

cd $(realpath $(dirname $0))/..
USBCHECKED=0

if [ $(pwd | grep mmcblk1) != '' ]; then
    echo ProgramRunFromTopSD
fi

while [ 1 ];
do
    read -r -t 1 LINE
    >&2 echo "$LINE"
    
    if [ "$LINE" = "Syscheck" ];
    then # check readiness of SD card and USB flash drive
    
        # check presence of SD card in top slot 
        LSDEV=$(ls /dev | grep mmcblk1)
        if [[ "$LSDEV" == '' ]]; then
            echo TopSDMissing
        else
            if [ $(sfdisk -s /dev/mmcblk1) -lt 3730000 ]; then echo TopSDTooSmall
            else echo TopSDGood
            fi
            
            if [ $(cat /sys/block/mmcblk1/device/oemid) == 0x5344 ]; # SanDisk
            then echo TopSDVettedBrand
            else echo TopSDUnknownBrand
            fi
        fi
        if [[ $USBCHECKED == 0 ]]; then
                USBCHECKED=1
                echo USBCheckStart
                md5sum -c camUpdate/update.md5sum 2>&1
                echo USBCheckDone
        fi
    fi
    
    if [[ "$LINE" == "Start" ]]; then # User has pressed Proceed button to start update
        break
    fi
done

# unmount the SD card before writing the image
umount /media/mmcblk1*

#Update the Power Management IC if an update file is in the update drive's root directory:
PMICHEXFILE=camUpdate/Chronos1_4PowerController.X.production.hex
PMICHEXVERSION=7
if test -f "$PMICHEXFILE"; then
	echo "$PMICHEXFILE exists, checking for firmware update"

	# Check the PIC firmware version and update only if necessary.
	echo "Stopping power management daemon"
	killall camshutdown
	killall pcUtil
	PMICFWVERSION=$(/usr/local/sbin/pcUtil -v | sed -e 's/.*://' | tr -d '[:space:]')
	if [ "$PMICFWVERSION" -lt "$PMICHEXVERSION" ]; then
		echo "Updating PMIC Firmware"
		/usr/local/sbin/pcUtil -u $PMICHEXFILE
		/usr/local/sbin/pcUtil -q
	else
		echo "Found PMIC version $PMICFWVERSION Skipping PMIC firmware update"
	fi
fi


zcat camUpdate/debian.img.gz | dd of=/dev/mmcblk1 2>&1 & # normal
#zcat debian.img.gz | dd of=/dev/mmcblk1  count=100000 2>&1 & # testing

sleep 1
while [ 1 ];
do
    KILLALLRESULT="$(2>&1 killall -USR1 dd)"
    if [[ "$KILLALLRESULT" == '' ]]; then
        sleep 1 # If killall command was successful, KILLALL will be empty.
    else
        break # If killall command errored out, dd has finished or errored out.
    fi
done
echo WriteDone

while [ "$LINE" != "PowerDown" ];
do
    read -r -t 1 LINE
    >&2 echo "$LINE"
done
>&2 echo "update_backend.sh completed!"
shutdown -h now
