#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
SYSROOT=$(pwd)/debian
SUITE=voyager
GUIPACKAGE=chronos-gui
IMAGE=
SUDO=

## Show some help
show_help() {
   echo "Usage: $(basename ${BASH_SOURCE[0]}) [options]"
   echo ""
   echo "Bootstrap a Chronos/Debian base system into a target directory."
   echo ""
   echo "options:"
   echo "    -s SUITE Select SUITE as the release distribution. (defalt: ${SUITE})"
   echo "    -d DIR   Install root filesystem into DIR. (default: ${SYSROOT})"
   echo "    -i FILE  Create a filesystem image directly at FILE."
   echo "    -g       Select the GUI2 user interface."
   echo "    -h       Print this message and exit."
}

## Do argument parsing
OPTIND=1
while getopts "h?s:d:i:g" opt; do
   case "$opt" in
      h|\?)
         show_help
         exit 0
         ;;
      d)
         SYSROOT=$OPTARG
         ;;
      i)
	 IMAGE=$OPTARG
	 ;;
      g)
         GUIPACKAGE=chronos-gui2
         ;;
      s)
         SUITE=$OPTARG
         ;;
   esac
done
shift $((OPTIND-1))

## Ensure sbin is in our path...
export PATH=${PATH}:/usr/sbin:/sbin

## Check for some crucial tools before proceeding.
if [ -z "$(which multistrap)" ]; then
   echo "multstrap not found, please install before proceeding" >&2
   exit 1
fi
QEMU=$(which qemu-arm-static)
if [ -z "${QEMU}" ] && (dpkg --print-architecture | grep -qv ^arm); then
   echo "qemu-arm-static not found, please install QEMU before proceeding" >&2
   exit 1
fi

# We will need sudo if we are not root.
if [[ $EUID -ne 0 ]]; then
   SUDO=sudo
fi

## Cleanup block devices on exit.
function image_cleanup {
  pumount /media/chronos-debootstrap-rootfs
  pumount /media/chronos-debootstrap-bootpart
  ${SUDO} losetup -d ${BLOCKDEV}
}

if [ ! -z "${IMAGE}" ]; then
   ## Create and mount the loop device for image creation.
   ${DIR}/mksd-loopdev.sh ${IMAGE} || exit 1
   BLOCKDEV=$(/sbin/losetup -n -j ${IMAGE} -O NAME)

   pmount ${BLOCKDEV}p1 chronos-debootstrap-bootpart
   pmount -e ${BLOCKDEV}p2 chronos-debootstrap-rootfs
   trap image_cleanup EXIT

   cd ${DIR} && ${SUDO} SUITE=${SUITE} GUIPACKAGE=${GUIPACKAGE} BOOTPART=/media/chronos-debootstrap-bootpart \
	   multistrap -a armel -d /media/chronos-debootstrap-rootfs -f ${DIR}/chronos-${SUITE}.conf
else
   ## Debootstrap the filesystem into the sysroot.
   cd ${DIR} && ${SUDO} SUITE=${SUITE} GUIPACKAGE=${GUIPACKAGE} \
	   multistrap -a armel -d ${SYSROOT} -f ${DIR}/chronos-${SUITE}.conf
fi

