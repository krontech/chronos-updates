#!/bin/bash
SYSROOT="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/debian/"

# The partition we want to nuke
DEVICE=$1
if [ ! -b "$DEVICE" ]; then
 echo "Cowardly refusing to format '$DEVICE': Not a block device."
 exit 1
fi

## Unmount any existing partitions on the device
umount ${DEVICE} 2>/dev/null

## Format
mkfs.ext3 -j -L "ROOTFS" ${DEVICE}

## Mount it in a temporary location.
MOUNT=$(mktemp -d)
mount -t ext3 ${DEVICE} ${MOUNT}

## Copy the filesystem
rsync -a --info=progress2 ${SYSROOT} ${MOUNT}
umount ${MOUNT}
rmdir ${MOUNT}
