#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
SYSROOT=$(pwd)/debian
SUITE=voyager
GUIPACKAGE=chronos-gui
BOOTPART=
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
   echo "    -b DIR   Install bootloader filesystem into DIR."
   echo "    -g       Select the GUI2 user interface."
   echo "    -h       Print this message and exit."
}

## Do argument parsing
OPTIND=1
while getopts "h?s:d:b:g" opt; do
   case "$opt" in
      h|\?)
         show_help
         exit 0
         ;;
      d)
         SYSROOT=$OPTARG
         ;;
      b)
	 BOOTPART=$OPTARG
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

## Debootstrap the filesystem into the sysroot.
cd ${DIR} && ${SUDO} SUITE=${SUITE} GUIPACKAGE=${GUIPACKAGE} BOOTPART=${BOOTPART} \
	   multistrap -a armel -d ${SYSROOT} -f ${DIR}/chronos-${SUITE}.conf

