#!/bin/sh
killall camApp

# Show shutdown splash if camApp happens to exit for any reason.
bitmap=/opt/camera/shuttingDown.data
exitsplash() {
	echo "---<<< Showing Shutdown Splash >>>---"
	sleep 0.2s
	cat $bitmap > /dev/fb0
}
if [ -f $bitmap ]; then
	trap exitsplash EXIT
fi

# Run camApp
cd /opt/camera/
./camApp -qws -display transformed:rot0
exit 0

	
