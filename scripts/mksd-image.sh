#!/bin/bash
FILENAME=$1
BOOTDIR="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/rootfs/boot"
SYSROOT="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/debian"
BLOCKDEV=/dev/loop0
BOOTPART=${BLOCKDEV}p1
ROOTFSPART=${BLOCKDEV}p2

# Create an 8GB file for the block device.
touch ${FILENAME}
truncate -s 3500m ${FILENAME}

# Loopback device setup.
losetup -f ${FILENAME}
BLOCKDEV=$(losetup -n -j ${FILENAME} -O NAME)
BOOTPART=${BLOCKDEV}p1
ROOTFSPART=${BLOCKDEV}p2

# Partition the device.
echo "Partitioning device"
dd if=/dev/zero of=${BLOCKDEV} bs=1k count=1024
sfdisk ${BLOCKDEV} << EOF
label: dos
label-id: 0x00000000
device: ${BLOCKDEV}
unit: sectors

${BOOTPART} : start=63,    type=c, size=80262, bootable
${ROOTFSPART} : start=80325, type=83, size=15429687
EOF
partprobe ${BLOCKDEV}

# Install the bootloader
echo "Installing bootloader into ${BOOTPART}"
mkfs.vfat -F 32 -n BOOT ${BOOTPART}
BOOTMOUNT=$(mktemp -d)
mount -t vfat ${BOOTPART} ${BOOTMOUNT}
cp ${SYSROOT}/boot/uboot ${BOOTMOUNT}
umount ${BOOTMOUNT}
rmdir ${BOOTMOUNT} 

# Install the root filesystem.
echo "Installing root filesystem into ${ROOTFSPART}"
mkfs.ext3 -j -L "ROOTFS" ${ROOTFSPART}
ROOTFSMOUNT=$(mktemp -d)
mount -t ext3 ${ROOTFSPART} ${ROOTFSMOUNT}
rsync -a --info=progress2 ${SYSROOT}/ ${ROOTFSMOUNT}
umount ${ROOTFSMOUNT}
rmdir ${ROOTFSMOUNT}

# Unmount the loop device.
losetup -d ${BLOCKDEV}

