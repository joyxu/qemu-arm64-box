#!/bin/sh

cd work

# Remove the old initramfs archive if it exists.
rm -f rootfs.cpio.gz

cd rootfs

# install applet
APPLETS=$(ls ../../source/applets/*arm64.tar.gz)
for patch in $APPLETS
do
	echo install applet: ${patch} ...
	tar -zxvf ${PWD}/../../source/applets/${patch} -C ${PWD}
done

# Packs the current folder structure in "cpio.gz" archive.
find . | cpio -H newc -o | gzip > ../rootfs.cpio.gz

cd ../..

