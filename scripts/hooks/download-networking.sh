#!/bin/bash
SYSROOT=$1

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

# Setup udhcpd to serve leases on the USB gadget interface.
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
