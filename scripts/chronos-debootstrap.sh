#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
SYSROOT=$(pwd)/debian
SUITE=voyager
GUIPACKAGE=chronos-gui
EXTRAS=

## Show some help
show_help() {
   echo "Usage: $(basename ${BASH_SOURCE[0]}) [options]"
   echo ""
   echo "Bootstrap a Chronos/Debian base system into a target directory."
   echo ""
   echo "options:"
   echo "    -s SUITE Select SUITE as the release distribution. (defalt: ${SUITE})"
   echo "    -d DIR   Install root filesystem into DIR. (default: ${SYSROOT})"
   echo "    -g       Select the GUI2 user interface."
   echo "    -h       Print this message and exit."
}

## Do argument parsing
OPTIND=1
while getopts "h?s:d:g" opt; do
   case "$opt" in
      h|\?)
         show_help
         exit 0
         ;;
      d)
         SYSROOT=$OPTARG
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
if [ -z "$(which qemu-arm-static)" ]; then
   echo "qemu-arm-static not found, please install QEMU before proceeding" >&2
   exit 1
fi

## Boostrap the filesystem - root permissions are required.
cd ${DIR}
if [[ $EUID -ne 0 ]]; then
   sudo SUITE=${SUITE} GUIPACKAGE=${GUIPACKAGE} multistrap -a armel -d ${SYSROOT} -f ${DIR}/chronos-${SUITE}.conf
else
   SUITE=${SUITE} GUIPACKAGE=${GUIPACKAGE} multistrap -a armel -d ${SYSROOT} -f ${DIR}/chronos-${SUITE}.conf
fi
