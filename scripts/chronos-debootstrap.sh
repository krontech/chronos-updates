#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
SYSROOT=$(pwd)/debian
SUITE=voyager
GUIPACKAGE=chronos-gui
EXTRAS=

## Show some help
show_help() {
   echo "Usage: $(basename ${BASH_SOURCE[0]}) [options] [packages]"
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

## Any remaining arguments are packages to add.
EXTRAS=$@

## Check for some crucial tools before proceeding.
if [ -z "$(which multistrap)" ]; then
   echo "multstrap not found, please install before proceeding" >&2
   exit 1
fi
if [ -z "$(which qemu-arm-static)" ]; then
   echo "qemu-arm-static not found, please install QEMU before proceeding" >&2
   exit 1
fi
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script with root priveledges to enable chroot." >&2
   exit 1
fi

## Boostrap the filesystem.
(cd ${DIR} && multistrap -a armel -d ${SYSROOT} -f /dev/stdin) << EOF
$(cat ${DIR}/chronos-${SUITE}.conf)
packages=${GUIPACKAGE} ${EXTRAS}
EOF

## Create filesystem mountpoints.
mkdir -p ${SYSROOT}/boot/uboot
mkdir -p ${SYSROOT}/sys
mkdir -p ${SYSROOT}/proc

## Prepare to emulate the chroot
cat << EOF > ${SYSROOT}/usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod a+x ${SYSROOT}/usr/sbin/policy-rc.d
mv ${SYSROOT}/usr/bin/ischroot ${SYSROOT}/usr/bin/ischroot.debianutils
cp ${SYSROOT}/bin/true ${SYSROOT}/usr/bin/ischroot
cp $(which qemu-arm-static) ${SYSROOT}/usr/bin
mount -o bind /dev ${SYSROOT}/dev
mount -o bind /sys ${SYSROOT}/sys
mount -o bind /proc ${SYSROOT}/proc

## Cleanup the chroot on exit
function atexit {
	umount -l ${SYSROOT}/dev
	umount -l ${SYSROOT}/sys
	umount -l ${SYSROOT}/proc
	rm ${SYSROOT}/usr/bin/qemu-arm-static
	rm ${SYSROOT}/usr/sbin/policy-rc.d
	rm ${SYSROOT}/usr/bin/ischroot
	mv ${SYSROOT}/usr/bin/ischroot.debianutils ${SYSROOT}/usr/bin/ischroot
}
trap atexit EXIT

cat << EOF > ${SYSROOT}/etc/apt/sources.list.d/krontech-debian.list
deb http://debian.krontech.ca/apt/debian/ ${SUITE} main
EOF

cat << EOF > ${SYSROOT}/etc/apt/sources.list.d/backports-debian.list
deb [arch=armel] http://archive.debian.org/debian jessie-backports main contrib non-free
EOF

cat << EOF > ${SYSROOT}/etc/apt/apt.conf.d/80backport-keys
# Disable key validity time to enable jessie-backports
Acquire::Check-Valid-Until "false";
EOF

## Configure the packages using chroot/qemu
chroot ${SYSROOT} /var/lib/dpkg/info/dash.preinst install
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C \
	chroot ${SYSROOT} dpkg --configure -a

## Configure en_US:UTF-8 as the default locale.
sed -i 's/^# *\(en_US.UTF-8\)/\1/' ${SYSROOT}/etc/locale.gen
cat << EOF > ${SYSROOT}/etc/default/locale
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
EOF
chroot ${SYSROOT} locale-gen

## Provide a root password
echo "root:chronos" | chroot ${SYSROOT} chpasswd

## Setup the filesystems
cat << EOF > ${SYSROOT}/etc/fstab
# <filesystem>  <mount point>   <type>  <options>           <dump/pass>
rootfs          /               auto    defaults            1  1
/dev/mmcblk0p1  /boot/uboot     vfat    defaults            0  0
proc            /proc           proc    defaults            0  0
devpts          /dev/pts        devpts  mode=0620,gid=5     0  0
usbfs           /proc/bus/usb   usbfs   defaults            0  0
tmpfs           /var/volatile   tmpfs   defaults,size=16M   0  0
tmpfs           /dev/shm        tmpfs   mode=0777           0  0
tmpfs           /media/ram      tmpfs   defaults,size=16M   0  0
EOF

##-------------------
## Setup networking
##-------------------
echo chronos > ${SYSROOT}/etc/hostname
touch ${SYSROOT}/etc/udev/rules.d/75-persistent-net-generator.rules

# Setup the USB gadget as an Ethernet device.
cat << EOF > ${SYSROOT}/etc/network/interfaces
## Loopback interface
auto lo
iface lo inet loopback

## Ethernet/RNDIS gadget
auto usb0
iface usb0 inet static
	address 192.168.12.1
	netmask 255.255.255.0
EOF

# Setup udhcpd to server leases on the USB gadget interface.
cat << EOF > ${SYSROOT}/etc/udhcpd.conf
## udhcpd configuration file (/etc/udhcpd.conf) for local USB networking

# The start and end of the IP lease block
start			192.168.12.20
end				192.168.12.254
option subnet	255.255.255.0

# The interface that udhcpd will use
interface		usb0
EOF

cat << EOF > ${SYSROOT}/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo g_ether >> ${SYSROOT}/etc/modules

sed -i 's/\(DHCPD_ENABLED=\)/#\1/' ${SYSROOT}/etc/default/udhcpd


cat << EOF >> ${SYSROOT}/etc/ssh/sshd_config

# Permit local root login via USB
Match Address 192.168.12.*,127.0.0.1,::1
	PermitRootLogin yes

EOF

##-----------------------------
## Setup the console and UART
##-----------------------------
echo S:2345:respawn:/sbin/getty -L ttyO4 115200 vt100 >> ${SYSROOT}/etc/inittab
sed -i '/ttyO3/a ttyO4\nttyO5' ${SYSROOT}/etc/securetty
cat << EOF >> ${SYSROOT}/root/.bashrc
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
EOF

##------------------------------
## Add a hardware init script.
##------------------------------
cp ${DIR}/hwsetup.sh ${SYSROOT}/etc/init.d/
LC_ALL=C LANGUAGE=C LANG=C chroot ${SYSROOT} update-rc.d hwsetup.sh start 10 S stop 90 0 6
