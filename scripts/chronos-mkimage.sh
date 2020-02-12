#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"

# We require at least one argument for the image name.
if [ $# -lt 1 ]; then
   echo "Usage: $(basename ${BASH_SOURCE[0]}) [options] IMAGE"
   echo ""
   echo "Bootstrap a Chronos/Debian base system and package it into an SD card image."
   echo ""
   echo "options:"
   echo "    -s SUITE Select SUITE as the release distribution. (defalt: ${SUITE})"
   echo "    -g       Select the GUI2 user interface."
   echo "    -h       Print this message and exit."
   exit 1
fi
IMAGENAME=${@:$#}
SUDO=

## Ensure we have sbin in our path.
PATH=${PATH}:/usr/sbin:/sbin

# We will need sudo if we are not root.
if [[ $EUID -ne 0 ]]; then
   SUDO=sudo
fi

## The partition sizes and filenames.
PTABLE_FILE=${IMAGENAME%.*}.ptable.img
BOOTPART_FILE=${IMAGENAME%.*}.boot.vfat.img
ROOTFS_FILE=${IMAGENAME%.*}.rootfs.ext3.img
BOOTPART_SIZE=80262
ROOTFS_SIZE=7168000

## Create the partition table.
echo -e "${SC_BOLD}Partitioning image at ${IMAGENAME}${ESC_NORMAL}"
dd if=/dev/zero of=${PTABLE_FILE} bs=1k count=1024
truncate -s $(((BOOTPART_SIZE+ROOTFS_SIZE+63)*512)) ${PTABLE_FILE}
/sbin/sfdisk -f ${PTABLE_FILE} << EOF
label: dos
label-id: 0x00000000
device: ptable.img
unit: sectors

${IMAGENAME}p1 : start=63, type=c, size=$((BOOTPART_SIZE)), bootable
${IMAGENAME}p2 : start=$((BOOTPART_SIZE+63)), type=83, size=$((ROOTFS_SIZE))
EOF
## Create the filesysem images.
truncate -s $((63*512)) ${PTABLE_FILE}
truncate -s $((BOOTPART_SIZE * 512)) ${BOOTPART_FILE}
truncate -s $((ROOTFS_SIZE * 512)) ${ROOTFS_FILE}
mkfs.vfat -F32 -n BOOT ${BOOTPART_FILE}
mkfs.ext3 -L ROOTFS ${ROOTFS_FILE}

## Mount the partitons as loop devices. 
BOOTPART_DEV=$(${SUDO} losetup --show -f ${BOOTPART_FILE})
ROOTFS_DEV=$(${SUDO} losetup --show -f ${ROOTFS_FILE})
pmount ${BOOTPART_DEV} chronos-mkimage-bootpart
pmount -e ${ROOTFS_DEV} chronos-mkimage-rootfs

## Cleanup when we're finished.
function atexit {
   pumount /media/chronos-mkimage-bootpart
   pumount /media/chronos-mkimage-rootfs
   ${SUDO} losetup -d ${BOOTPART_DEV}
   ${SUDO} losetup -d ${ROOTFS_DEV}
   rm ${PTABLE_FILE}
   rm ${BOOTPART_FILE}
   rm ${ROOTFS_FILE}
}
trap atexit EXIT

## Debootstrap the filesystem.
# This variable madness is try to pass the all the script arguments, with
# the final argument (image name) removed to chronos-debootstrap.sh
${DIR}/chronos-debootstrap.sh ${@:1:$(($#-1))} -d /media/chronos-mkimage-rootfs -b /media/chronos-mkimage-bootpart
ERR=$?
if [ $ERR -ne 0 ]; then
   echo "Image bootstrap failed. Exiting..." >&2
   exit $ERR
fi

## Assemble the filesystem image, and optionally compress by suffix.
case ${IMAGENAME##*.} in
   gz)
      gzip -c ${PTABLE_FILE} > ${IMAGENAME}
      gzip -c ${BOOTPART_FILE} >> ${IMAGENAME}
      gzip -c ${ROOTFS_FILE} >> ${IMAGENAME}
      ;;
   bz2)
      bzip2 -c ${PTABLE_FILE} > ${IMAGENAME}
      bzip2 -c ${BOOTPART_FILE} >> ${IMAGENAME}
      bzip2 -c ${ROOTFS_FILE} >> ${IMAGENAME}
      ;;
   xz)
      xz -c --threads=0 ${PTABLE_FILE} > ${IMAGENAME}
      xz -c --threads=0 ${BOOTPART_FILE} >> ${IMAGENAME}
      xz -c --threads=0 ${ROOTFS_FILE} >> ${IMAGENAME}
      ;;
   *)
      cat ${PTABLE_FILE} > ${IMAGENAME}
      cat ${BOOTPART_FILE} >> ${IMAGENAME}
      cat ${ROOTFS_FILE} >> ${IMAGENAME}
      ;;
esac

