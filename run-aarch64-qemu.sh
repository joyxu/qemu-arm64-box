#!/bin/sh -e

KERNEL=./Image
INITRD=./rootfs.cpio.gz
HOST_NET=false
BIOS=false
UBUNTU_BIOS_IMG="https://cloud-images.ubuntu.com/releases/16.04/release-20160516.1/ubuntu-16.04-server-cloudimg-amd64-uefi1.img"
UBUNTU_IMG_PATH="./test/ubuntu-cloudimg-arm64-uefi1.img"
#please change the tap0 ip address according your network

prepare_host_network()
{
	if ifconfig | grep tap0 ; then
		echo "tap is already configured."
	else
		sudo tunctl -t tap0
		sudo ifconfig tap0 192.168.2.2 netmask 255.255.255.0 up
		sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

		# Create forwarding rules, where
		# tap0 - virtual interface
		# ETH0 - net connected interface
		ETH0=$(ip addr | grep 'state UP' | cut -f2 -d':' | xargs)
		iptables -A FORWARD -i tap0 -o $ETH0 -j ACCEPT
		iptables -t nat -A POSTROUTING -o $ETH0 -j MASQUERADE
		iptables -A FORWARD -i $ETH0 -o tap0 -m state \
			--state ESTABLISHED,RELATED -j ACCEPT
	fi
}

run_qemu()
{
	# generate a random mac address for the QEMU nic
	MAC_ADDRESS=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((`hexdump -n 1 -e '/2 \
	"%u"' /dev/urandom`)) $((`hexdump -n 1 -e '/2 "%u"' /dev/urandom`)))
	echo "MAC_ADDRESS=$MAC_ADDRESS"

	if [ -e $BIOS ]; then
		echo "booting with $BIOS"
		if [ ! -e $UBUNTU_IMG_PATH ]; then
			echo "downloading ubuntu cloud image..."
			mkdir -p test
			wget -c $UBUNTU_BIOS_IMG -O $UBUNTU_IMG_PATH
		fi

		sudo qemu-system-aarch64 \
			-machine virt \
			-cpu cortex-a57 \
			-smp 2 \
			-m 4096 \
			-bios $BIOS \
			-rtc base=localtime \
			-device virtio-blk-device,drive=image1 \
			-drive if=none,id=image1,file=$UBUNTU_IMG_PATH \
			-netdev type=tap,id=unet,ifname=tap0,script=no \
			-device virtio-net-device,netdev=unet,mac=$MAC_ADDRESS \
			-nographic
	else
		if [ -e $HOST_NET ]; then
			sudo qemu-system-aarch64 \
				-machine virt \
				-cpu cortex-a57 \
				-smp 2 \
				-m 4096 \
				-kernel $KERNEL \
				-rtc base=localtime \
				-initrd ${INITRD} \
				-append 'console=ttyAMA0 rw earlycon=pl011,0x9000000 \
				ip=192.168.2.3::192.168.2.2:255.255.255.0:: \
				eth0:on:192.168.2.2:8.8.8.8' \
				-netdev type=tap,id=unet,ifname=tap0,script=no \
				-device virtio-net-device,netdev=unet,mac=$MAC_ADDRESS \
				-nographic
		else
			sudo ~/qemu/build/aarch64-softmmu/qemu-system-aarch64 -s \
				-machine virt,kernel_irqchip=on,gic-version=3 \
				-cpu host -enable-kvm \
				-smp 2 \
				-m 4096 \
				-kernel $KERNEL \
				-device virtio-blk-device,drive=image1 \
				-drive if=none,id=image1,file=mini_rootfs_ext4.img \
				-rtc base=localtime \
				-netdev user,id=user0,hostfwd=tcp::5000-:22 \
				-device virtio-net-pci,netdev=user0 \
				-append 'nokaslr console=ttyAMA0 earlycon kmemleak=on root=/dev/vda mem=1G' \
				-nographic
		fi
	fi
}

if [ $1 ]; then
	BIOS=$1
fi

if [ $2 ]; then
	KERNEL=$2
fi

if [ $3 ]; then
	INITRD=$3
fi

#prepare_host_network
run_qemu
