#!/bin/bash
SYSROOT=$(pwd)/debian

mv ${SYSROOT}/usr/bin/ischroot ${SYSROOT}/usr/bin/ischroot.debianutils
cp ${SYSROOT}/bin/true ${SYSROOT}/usr/bin/ischroot
cp $(which qemu-arm-static) ${SYSROOT}/usr/bin
mount -o bind /dev ${SYSROOT}/dev
function atexit {
    rm ${SYSROOT}/usr/bin/ischroot
    mv ${SYSROOT}/usr/bin/ischroot.debianutils ${SYSROOT}/usr/bin/ischroot
    umount -l ${SYSROOT}/dev
}
trap atexit EXIT

## Do the chroot
chroot ${SYSROOT}
