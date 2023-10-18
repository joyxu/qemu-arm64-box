#!/bin/bash

TARGET="mini_rootfs_ext4.img"
ARM64_ROOT="ubuntu_minifs"
UBUNTU_BASE_URL=http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.1-base-arm64.tar.gz

APP_LIST="bash blkid dcbtool dhclient dmidecode e2fsck ethtool fdisk file fio fsck 
gdb ifconfig iozone ip tree iperf3 iperf ipmitool iw jq ledmon lldptool lsblk 
lscpu lspci lsscsi ltrace mdadm mkfs netperf numactl ssh sshd scp parted python3 
qperf rdma setcap setpci sfdisk sg strace stress taskset tc tcpdump vnstat 
ldd htop ib_send_bw"

PACK_LIST="perftest ibverbs-providers"


TMP_ROOT=${PWD}/${ARM64_ROOT}

sudo apt install qemu-user-static

function prepare() {
	if [ ! -e ${UBUNTU_BASE_URL##*/} ]; then
		wget -c ${UBUNTU_BASE_URL}
	fi

	if [ ! -d ${ARM64_ROOT} ]; then
		dd if=/dev/zero of=${TARGET} bs=1M count=4096 oflag=direct
		mkfs.ext4 ${TARGET}
		mkdir -p ${ARM64_ROOT}
		mount -t ext4 ${TARGET} ${ARM64_ROOT}/
		cd ${ARM64_ROOT}
		echo "current dir" ${PWD}
		tar xzf ../${UBUNTU_BASE_URL##*/}
		sudo cp /usr/bin/qemu-aarch64-static usr/bin/
		cp ../source/applets/base.tar.gz root/
		cp ../source/applets/openssh.tar.gz root/
		cp ../create_ubuntu_minifs.sh ./
		cp /etc/resolv.conf etc/resolv.conf
		sed -i "s/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" etc/apt/sources.list
		echo "127.0.0.1" > etc/hosts

		cd ..
		fi
	}

function cp_deps() {
	D=/root/tmp
	mkdir -p ${D}
	for library in $(ldd "$(which $1)" | cut -d '>' -f 2 | awk '{print $1}')
	do
		[ -f "${library}" ] && cp -farpv --parents "${library}"* "${D}"
	done

	find ${D} -type l -! -exec test -e {} \; -print | xargs rm
	cp -farpv --parents $(which $1) ${D}/
	cd ${D}; tar czf ../$1.arm64.tar.gz ./; cd -
	rm -rf ${D}
}

function pack_apps() {
	for app in ${APP_LIST}
	do
		[ -f "$(which ${app})" ] && echo "packing... " ${app}
		cp_deps ${app}
		echo "packed " ${app}
	done
}

function cp_package() {
	D=/root/tmp
	mkdir -p ${D}
	for item in $(dpkg-query -L $1)
	do
		[ -f ${item} ] && cp -farpv --parents ${item} ${D}
	done
	cd ${D}; tar czf ../$1.arm64.tar.gz ./; cd -
	rm -rf ${D}
}

function pack_packages() {
	for app in ${PACK_LIST}
	do
		echo "packing... " ${app}
		apt install  ${app}
		cp_package ${app}
		echo "packed " ${app}
	done
}

function sync_fs() {
	echo "Mounting file system to" ${PWD}/${ARM64_ROOT}
	mount -t proc	/proc	 ${TMP_ROOT}/proc
	mount -t sysfs	/sys	 ${TMP_ROOT}/sys
	mount -o bind	/dev	 ${TMP_ROOT}/dev
	mount -o bind	/dev/pts ${TMP_ROOT}/dev/pts

	echo "Change root"
	chroot  ${TMP_ROOT} /bin/bash -x <<'EOF'
echo "installing applets"
apt update

APT_PKG="iproute2 ethtool isc-dhcp-client lldpad dmidecode fio gdb net-tools 
iozone3 iperf3 libc-bin tree iperf ipmitool iw jq ledmon lldpad lsscsi ltrace 
mdadm netperf numactl openssh-server parted qperf pciutils strace stress 
tcpdump vnstat htop perftest ibverbs-providers binutils"

DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata
apt install -y ${APT_PKG}
apt-get clean
echo "finished installing applets"
./create_ubuntu_minifs.sh p
umount -lf /
EOF

	echo "Change root again"
	mount -t ext4 ${TARGET} ${ARM64_ROOT}/
	chroot  ${TMP_ROOT} /bin/bash -x <<'EOF'
cd /root
mkdir -p base
cd base
tar xzf ../base.tar.gz
find ./ -type f -name "*.so" -exec rm {} \;
cp --parent -farpv $(find ./ -type l  -exec bash -c "rm {}; echo {} | cut -c2- | cut -f1 -d'.'| sed 's/$/\*/g' " \;) ./
cp --parent -farpv /lib/aarch64-linux-gnu/ld* ./
tar czf ../base.arm64.tar.gz ./

cd ..
mkdir -p openssh
cd openssh
tar xzf ../openssh.tar.gz
find ./ -type f -name "*.so" -exec rm {} \;
tar czf ../sshd.arm64.tar.gz ./
EOF

	cp ${ARM64_ROOT}/root/*.arm64.tar.gz source/applets/
	chroot  ${TMP_ROOT} /bin/bash -x <<'EOF'
mount -t proc /proc /proc
umount -l /dev/loop0
EOF
}

if [ "$1" = "p" ]; then
	pack_apps
	pack_packages
else
	prepare
	sync_fs
fi
