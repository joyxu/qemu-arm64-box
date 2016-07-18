#!/bin/sh -ex

KERNEL=./Image
INITRD=./rootfs.cpio

if [ $1 ]; then
	KERNEL=$1
fi

if [ $2 ]; then
	INITRD=$2
fi

# generate a random mac address for the QEMU nic
export MAC_ADDRESS=$(printf 'DE:AD:BE:EF:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))
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
	-append 'console=ttyAMA0 rw earlycon=pl011,0x9000000' \
	-device virtio-net-device,netdev=net7,mac=$MAC_ADDRESS \
	-netdev type=tap,id=net7,script=no,downscript=no,ifname="tap1" \
	-nographic
