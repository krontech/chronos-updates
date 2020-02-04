#!/bin/bash
SYSROOT=$1

# Setup the console and UART
echo S:2345:respawn:/sbin/getty -L ttyO4 115200 vt100 >> ${SYSROOT}/etc/inittab
sed -i '/ttyO3/a ttyO4\nttyO5' ${SYSROOT}/etc/securetty
cat << EOF >> ${SYSROOT}/root/.bashrc
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
EOF

