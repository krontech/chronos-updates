#!/bin/bash
BLOCKDEV=$1
SYSROOT="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)/debian"

ESC_BOLD='\033[1m'
ESC_NORMAL='\033[0m'

if [ ! -b "$BLOCKDEV" ]; then
   echo "Cowardly refusing to format '$BLOCKDEV': Not a block device."
fi
# If the block device ends in a digit, the partition suffix is p1, p2, and etc.
if [ -z $(echo ${BLOCKDEV} | grep '[0-9]$') ]; then
   BOOTPART=${BLOCKDEV}1
   ROOTFSPART=${BLOCKDEV}2
else
   BOOTPART=${BLOCKDEV}p1
   ROOTFSPART=${BLOCKDEV}p2
fi

# Unmount all partitions
echo ""
echo -e "${ESC_BOLD}Unmounting partitions${ESC_NORMAL}"
for part in $(lsblk -n -o MOUNTPOINT ${BLOCKDEV}); do
   umount $part
done

# Partition the device.
echo ""
echo -e "${ESC_BOLD}Partitioning device${ESC_NORMAL}"
dd if=/dev/zero of=${BLOCKDEV} bs=1k count=1024
sfdisk ${BLOCKDEV} << EOF
label: dos
label-id: 0x00000000
device: ${BLOCKDEV}
unit: sectors

${BOOTPART} : start=63,    type=c, size=80262, bootable
${ROOTFSPART} : start=80325, type=83
EOF
partprobe ${BLOCKDEV}
sleep 0.5

# Install the bootloader
echo ""
echo -e "${ESC_BOLD}Installing bootloader into ${BOOTPART}${ESC_NORMAL}"
mkfs.vfat -F 32 -n BOOT ${BOOTPART}
BOOTMOUNT=$(mktemp -d)
mount -t vfat ${BOOTPART} ${BOOTMOUNT}
rsync -a --info=progress2 ${SYSROOT}/boot/uboot/ ${BOOTMOUNT}
umount ${BOOTMOUNT}
rmdir ${BOOTMOUNT} 

# Install the root filesystem.
echo ""
echo -e "${ESC_BOLD}Installing root filesystem into ${ROOTFSPART}${ESC_NORMAL}"
mkfs.ext3 -j -L "ROOTFS" ${ROOTFSPART}
ROOTFSMOUNT=$(mktemp -d)
mount -t ext3 ${ROOTFSPART} ${ROOTFSMOUNT}
rsync -a --info=progress2 --exclude 'boot/uboot/*' ${SYSROOT}/ ${ROOTFSMOUNT}
umount ${ROOTFSMOUNT}
rmdir ${ROOTFSMOUNT}
