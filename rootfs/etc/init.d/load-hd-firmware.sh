#!/bin/sh
#
# manage HDVICP2 and HDVPSS Engine firmware

PATH=$PATH:/usr/share/ti/ti-media-controller-utils
HDVICP2_ID=1
HDVPSS_ID=2

configure_lcd()
{
    echo "Configuring fb0 to LCD"
    
    echo 0 > /sys/devices/platform/vpss/display1/enabled
#    echo 33500,800/164/89/10,480/10/23/10,1 > /sys/devices/platform/vpss/display1/timings
    echo 33500,800/204/49/20,480/10/23/10,1 > /sys/devices/platform/vpss/display1/timings
    echo triplediscrete,rgb888,0/0/0/0 > /sys/devices/platform/vpss/display1/output
    echo 1 > /sys/devices/platform/vpss/display1/enabled
    echo 1:dvo2 > /sys/devices/platform/vpss/graphics0/nodes

    #Wait unfil fb0 exists before trying to set the resolution
    until [[ -e /dev/fb0 ]]
    do      
        echo "Waiting for /dev/fb0 to appear"                                          
        sleep 0.5
    done
    fbset -xres 800 -yres 480 -vxres 800 -vyres 1440
}


case "$1" in
    start)
        echo "Loading HDVICP2 Firmware"
        prcm_config_app s
        modprobe syslink
        until [[ -e /dev/syslinkipc_ProcMgr && -e /dev/syslinkipc_ClientNotifyMgr ]]
        do                                                
            sleep 0.5
        done
        firmware_loader $HDVICP2_ID /usr/share/ti/ti-media-controller-utils/dm814x_hdvicp.xem3 start -i2c 0
        echo "Loading HDVPSS Firmware"
        firmware_loader $HDVPSS_ID /usr/share/ti/ti-media-controller-utils/dm814x_hdvpss.xem3 start -i2c 0
#        modprobe vpss sbufaddr=0xBFB00000 mode=hdmi:1080p-60 i2c_mode=0
	modprobe vpss sbufaddr=0xBFB00000 mode=dvo2:800x480@60 i2c_mode=0

        modprobe ti81xxfb vram=0:24M,1:16M,2:6M
        configure_lcd
        modprobe ti81xxhdmi
#        modprobe tlc59108
      ;;
    stop)
        echo "Unloading HDVICP2 Firmware"
        firmware_loader $HDVICP2_ID /usr/share/ti/ti-media-controller-utils/dm814x_hdvicp.xem3 stop
        echo "Unloading HDVPSS Firmware"
#        rmmod tlc59108
        rmmod ti81xxhdmi
        rmmod ti81xxfb
        rmmod vpss
        firmware_loader $HDVPSS_ID /usr/share/ti/ti-media-controller-utils/dm814x_hdvpss.xem3 stop
        rm /tmp/firmware.$HDVPSS_ID
        rmmod syslink
      ;;
    *)
        echo "Usage: /etc/init.d/load-hd-firmware.sh {start|stop}"
        exit 1
        ;;
esac

exit 0
