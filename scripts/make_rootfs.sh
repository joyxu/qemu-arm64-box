#!/bin/sh

sudo apt-get install debootstrap qemu-user-static schroot

dd if=/dev/zero of=./rootfs.img bs=1M count=4000
mke2fs -t ext4 ./rootfs.img
mkdir ./test
sudo mount -o loop ./rootfs.img ./test

wget -c http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.3-base-arm64.tar.gz
sudo tar -xzvf ubuntu-base-20.04.3-base-arm64.tar.gz -C test/
#sudo cp -a /usr/bin/qemu-aarch64-static test/usr/bin/

cd test
sudo cp /etc/apt/sources.list ./etc/apt/sources.list
cd ..

sudo chroot test/

#change root passwd
passwd

#echo “nameserver xxxx” >> /etc/resolv.conf
apt update

#install gui package
apt install xorg -y
apt install –no-install-recommends lightdm-gtk-greeter -y
apt install –no-install-recommends lightdm -y
apt install –no-install-recommends openbox -y

exit
umount ./test
