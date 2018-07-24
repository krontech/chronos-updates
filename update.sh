#! /bin/sh
# Script to perform software update for Chronos 1.4 camera
#
# Author: David Kronstein, Kron Technologies Inc.
#       : 
#
# command to terminate camApp: killall -s SIGTERM camApp
#VERSION="0.4"

execute ()
{
    $* >/dev/null
    if [ $? -ne 0 ]; then
        echo
        echo "ERROR: executing $*"
        echo
        exit 1
    fi
}

version ()
{
  echo
  echo "`basename $1` version $VERSION"
  echo "Script to create bootable SD card for DM814x EVM"
  echo

  exit 0
}

usage ()
{
  echo "
Usage: `basename $1` <options> [ files for install partition ]

Mandatory options:
  --device              SD block device node (e.g /dev/sdd)
  --sdk                 Where is sdk installed ?

Optional options:
  --version             Print version.
  --help                Print this help message.
"
  exit 1
}

cd /
cd /media/sda1/camUpdate/

echo "Stopping camApp"
killall -s SIGTERM camApp

echo "Stopping power monitor..."
/etc/init.d/pwrmonitor stop
echo "Power monitor stopped."

cp camApp /opt/camera
cp camAppRevision /opt/camera
#cp FPGA.bit /opt/camera

#./pcUtil -u Chronos1_4PowerControllerCombinedV2.hex
#./pcUtil -i

echo "Restarting power monitor..."
/etc/init.d/pwrmonitor start
echo "Power monitor restarted."

cd /
cd /opt/camera/
echo "Starting capApp"
./camApp -qws &

echo "completed!"
exit 0

