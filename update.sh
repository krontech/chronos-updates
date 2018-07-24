#! /bin/sh
# Script to perform software update for Chronos 1.4 camera
#
# Author: David Kronstein, Kron Technologies Inc.
#       : 
#
# command to terminate camApp: killall -s SIGTERM camApp

cd /
cd /media/sda1/camUpdate/

echo "Stopping camApp"
killall -s SIGTERM camApp

cp camApp /opt/camera
cp FPGA.bit /opt/camera
cp camAppRevision /opt/camera

cd /
cd /opt/camera/
echo "Starting capApp"
./camApp -qws &

echo "completed!"
exit 0

