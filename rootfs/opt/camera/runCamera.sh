killall camApp

cd /opt/camera/
./camApp -qws

bitmap=/opt/camera/shuttingDown.data
if [ -f $bitmap ]; then
	while true; do
		ps_out=$(ps)
		grep_out=$(echo $ps_out | grep camApp)
		if [[ "$grep_out" == "" ]]; then
			break
		else
			sleep 0.1s
		fi
	done
	echo "---<<< Showing Shutdown Splash >>>---"
	sleep 0.2s
	cat $bitmap > /dev/fb0
	sleep 0.2s
fi

exit 0

	
