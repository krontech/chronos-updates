#!/bin/bash
SYSROOT=$1

## Setup the filesystems
cat << EOF > ${SYSROOT}/etc/fstab
# <filesystem>  <mount point>   <type>  <options>           <dump/pass>
rootfs          /               auto    defaults            1  1
/dev/mmcblk0p1  /boot/uboot     vfat    defaults            0  0
proc            /proc           proc    defaults            0  0
devpts          /dev/pts        devpts  mode=0620,gid=5     0  0
usbfs           /proc/bus/usb   usbfs   defaults            0  0
tmpfs           /var/volatile   tmpfs   defaults,size=16M   0  0
tmpfs           /dev/shm        tmpfs   mode=0777           0  0
tmpfs           /media/ram      tmpfs   defaults,size=16M   0  0
EOF

