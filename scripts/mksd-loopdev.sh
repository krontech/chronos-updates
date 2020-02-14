#!/bin/bash
# Usage: mksd-loopdev.sh <IMAGENAME>
#
# Create and format an SD card image and mount it as a loopback
# device, and print the loopback device name to stdout if successful.
DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
IMAGENAME=$1
SUDO=

# We will require sudo if not already root to properly use losetup.
if [[ $EUID -ne 0 ]]; then
   SUDO=sudo
fi

# Redirect all of stdout to stderr, and keep the stdout as fd 3 for later.
exec 3>&1 1>&2
ESC_BOLD='\033[1m'
ESC_NORMAL='\033[0m'

# Create a 4GB file and partition it.
echo -e "${SC_BOLD}Partitioning image at ${IMAGENAME}${ESC_NORMAL}"
dd if=/dev/zero of=${IMAGENAME} bs=1k count=1024
truncate -s 3500m ${IMAGENAME}
/sbin/sfdisk ${IMAGENAME} << EOF
label: dos
label-id: 0x00000000
device: ${IMAGENAME}
unit: sectors

${IMAGENAME}p1 : start=63, type=c, size=80262, bootable
${IMAGENAME}p2 : start=80325 type=83
EOF

# Mount the loopback devices.
BLOCKDEV=$(${SUDO} losetup --show -P -f ${IMAGENAME})
BOOTPART=${BLOCKDEV}p1
ROOTFSPART=${BLOCKDEV}p2
echo -e "${ESC_BOLD}Setup ${IMAGENAME} as ${BLOCKDEV}${ESC_NORMAL}"
sleep 0.1

# Format the bootloader partition
echo ""
echo -e "${ESC_BOLD}Formatting bootloader partition at ${BOOTPART}${ESC_NORMAL}"
if ! /sbin/mkfs.vfat -F 32 -n BOOT ${BOOTPART}; then
   ${SUDO} losetup -d ${BLOCKDEV}
   exit 1
fi

# Format the root filesystem.
echo ""
echo -e "${ESC_BOLD}Formatting root filesystem partiton at ${ROOTFSPART}${ESC_NORMAL}"
if ! /sbin/mkfs.ext3 -j -L "ROOTFS" ${ROOTFSPART}; then
  ${SUDO}losetup -d ${BLOCKDEV}
  exit 1
fi

# Output the resulting loop device on the real stdout.
echo "${BLOCKDEV}" >&3

