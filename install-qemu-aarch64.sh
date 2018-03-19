#!/bin/bash -ex

sudo apt-get build-dep qemu
#sudo apt-get install -y libtool automake autoconf pkg-config
#sudo apt-get install -y git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev

#add tun/tap support
sudo apt-get install uml-utilities bridge-utils

# install QEMU from source
if [ ! -e qemu.git ]
then
	git clone git://git.qemu.org/qemu.git qemu.git
fi
cd qemu.git
./configure --prefix=/usr/local --target-list=aarch64-softmmu --enable-fdt --enable-vhost-net --enable-kvm
make -j4
sudo make install
