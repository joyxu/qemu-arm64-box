#!/bin/sh

qemu-system-aarch64 -machine virt,kernel_irqchip=on,gic-version=3 \
	-cpu host -enable-kvm -smp 4 \
	-m 8G \
	-kernel ./Image \
	-drive file=./rootfs.img,format=raw,if=none,id=hd0,readonly=off \
	-device virtio-blk-device,drive=hd0 \
	-netdev user,id=user0 \
	-device virtio-net-pic,netdev=user0 \
	-device virtio-gpu-pci-gl -display egl-headless \
	-vnc 0.0.0.0:53 \
	-device usb-ehci -device usb-kbd -device usb-tablet -usb \
	-fsdev local,security_model=passthrough,id=fsdev0,path=~/ \
	-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
	-append "root=/dev/vda rw" \
	-serial stdio

