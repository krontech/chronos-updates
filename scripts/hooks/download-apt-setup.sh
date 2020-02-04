#!/bin/bash
SYSROOT=$1

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

