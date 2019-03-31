#!/bin/bash
BLOCKDEV=$1
BOOTDIR="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/rootfs/boot/"
SYSROOT="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/debian/"
BOOTPART=${BLOCKDEV}1
ROOTFSPART=${BLOCKDEV}2

if [ ! -b "$BLOCKDEV" ]; then
   echo "Cowardly refusing to format '$BLOCKDEV': Not a block device."
fi

# Unmount all partitions
echo "Unmounting partitions"
for part in $(lsblk -n -o MOUNTPOINT /dev/sdb); do
   umount $part
done

# Partition the device.
echo "Partitioning device"
dd if=/dev/zero of=${BLOCKDEV} bs=1k count=1024
sfdisk ${BLOCKDEV} << EOF
label: dos
label-id: 0x00000000
device: ${BLOCKDEV}
unit: sectors

${BOOTPART} : start=63,    type=c, size=80262, bootable
${ROOTFSPART} : start=80325, type=83
EOF

# Install the bootloader
echo "Installing bootloader into ${BOOTPART}"
mkfs.vfat -F 32 -n BOOT ${BOOTPART}
BOOTMOUNT=$(mktemp -d)
mount -t vfat ${BLOCKDEV}1 ${BOOTMOUNT}
cp ${BOOTDIR}/boot.cmd ${BOOTMOUNT}
cp ${BOOTDIR}/boot.scr ${BOOTMOUNT}
cp ${BOOTDIR}/MLO      ${BOOTMOUNT}
cp ${BOOTDIR}/splash.bmp ${BOOTMOUNT}
cp ${BOOTDIR}/u-boot.bin ${BOOTMOUNT}
cp ${SYSROOT}/boot/vmlinuz-* ${BOOTMOUNT}/uImage
umount ${BOOTMOUNT}
rmdir ${BOOTMOUNT} 

# Install the root filesystem.
echo "Installing root filesystem into ${ROOFSPART}"
mkfs.ext3 -j -L "ROOTFS" ${ROOTFSPART}
ROOTFSMOUNT=$(mktemp -d)
mount -t ext3 ${ROOTFSPART} ${ROOTFSMOUNT}
rsync -a --info=progress2 ${SYSROOT} ${ROOTFSMOUNT}
umount ${ROOTFSMOUNT}
rmdir ${ROOTFSMOUNT}

