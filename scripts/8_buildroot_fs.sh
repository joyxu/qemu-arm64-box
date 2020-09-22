#!/bin/bash -ex

#compile buildroot from source
if [ ! -e buildroot.git ]
then
	git clone git://git.buildroot.net/buildroot buildroot.git
fi
cd buildroot.git
cp ../buildroot.config .config
make -j4
cp output/images/rootfs.cpio ../
