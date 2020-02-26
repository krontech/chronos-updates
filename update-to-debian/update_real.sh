#!/bin/busybox ash

cd $(realpath $(dirname $0))

#May fail, probably because they already exist. That's OK.
mkfifo /opt/camera/to-update-ui || true
mkfifo /opt/camera/to-update-backend || true

>&2 echo "stopping camApp"
killall camApp || true
sleep 0.8

>&2 echo "starting update-to-debian"
./update_backend.sh < /opt/camera/to-update-backend > /opt/camera/to-update-ui &
./update-to-debian -qws > /opt/camera/to-update-backend < /opt/camera/to-update-ui &

wait