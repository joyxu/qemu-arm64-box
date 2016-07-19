#!/bin/sh -e

KERNEL=./Image
INITRD=./rootfs.cpio

prepare_host_network()
{
	if ifconfig | grep tap0 ; then
		echo "tap is already configured."
	else
		sudo tunctl -t tap0
		sudo ifconfig tap0 192.168.0.2 netmask 255.255.255.0 up
		sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

		# Create forwarding rules, where
		# tap0 - virtual interface
		# ETH0 - net connected interface
		ETH0=$(ip addr | grep 'state UP' | cut -f2 -d':' | xargs)
		iptables -A FORWARD -i tap0 -o $ETH0 -j ACCEPT
		iptables -A FORWARD -i $ETH0 -o tap0 -m state \
			--state ESTABLISHED,RELATED -j ACCEPT
		iptables -t nat -A POSTROUTING -o $ETH0 -j MASQUERADE
	fi
}

run_qemu()
{
	# generate a random mac address for the QEMU nic
	MAC_ADDRESS=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((`hexdump -n 1 -e '/2 \
	"%u"' /dev/urandom`)) $((`hexdump -n 1 -e '/2 "%u"' /dev/urandom`)))
	echo "MAC_ADDRESS=$MAC_ADDRESS"

	sudo qemu-system-aarch64 \
		-machine virt \
		-cpu cortex-a57 \
		-smp 8 \
		-nographic \
		-m 8196 \
		-kernel $KERNEL \
		-rtc base=localtime \
		-initrd ${INITRD} \
		-append 'console=ttyAMA0 rw earlycon=pl011,0x9000000 \
		ip=192.168.0.3::192.168.0.2:255.255.255.0:: \
		eth0:on:192.168.0.2:8.8.8.8' \
		-netdev type=tap,id=unet,ifname=tap0,vlan=0,script=no \
		-device virtio-net-device,netdev=unet,mac=$MAC_ADDRESS \
		-nographic
}

if [ $1 ]; then
	KERNEL=$1
fi

if [ $2 ]; then
	INITRD=$2
fi

prepare_host_network
run_qemu
