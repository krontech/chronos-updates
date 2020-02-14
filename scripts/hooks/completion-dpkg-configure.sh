#!/bin/bash
DIR="$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)"
SYSROOT=$1
if dpkg --print-architecture | grep -qv ^arm; then
	QEMU=$(which qemu-arm-static)
fi

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
[ -z "${QEMU}" ] || cp ${QEMU} ${SYSROOT}/usr/bin
[ -z "${BOOTPART}" ] || mount -o bind ${BOOTPART} ${SYSROOT}/boot/uboot
mount -o bind /dev ${SYSROOT}/dev
mount -o bind /sys ${SYSROOT}/sys
mount -o bind /proc ${SYSROOT}/proc

## Cleanup the chroot on exit
function atexit {
	umount -l ${SYSROOT}/dev
	umount -l ${SYSROOT}/sys
	umount -l ${SYSROOT}/proc
	[ -z "${BOOTPART}" ] || umount -l ${SYSROOT}/boot/uboot
	[ -z "${QEMU}" ] || rm ${SYSROOT}/usr/bin/qemu-arm-static
	rm ${SYSROOT}/usr/sbin/policy-rc.d
	rm ${SYSROOT}/usr/bin/ischroot
	mv ${SYSROOT}/usr/bin/ischroot.debianutils ${SYSROOT}/usr/bin/ischroot
}
trap atexit EXIT

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

## Enable the desired GUI package.
echo "Enabling GUI=${GUIPACKAGE}"
chroot ${SYSROOT} systemctl enable ${GUIPACKAGE}

## Provide a root password
echo "root:chronos" | chroot ${SYSROOT} chpasswd

##------------------------------
## Add a hardware init script.
##------------------------------
cp ${DIR}/hwsetup.sh ${SYSROOT}/etc/init.d/
LC_ALL=C LANGUAGE=C LANG=C chroot ${SYSROOT} update-rc.d hwsetup.sh start 10 S stop 90 0 6
