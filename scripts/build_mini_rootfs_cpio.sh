#!/bin/sh

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

sh scripts/0_prepare.sh
#sh 1_get_kernel.sh
#sh 2_build_kernel.sh
#sh 3_get_busybox.sh
sh scripts/4_build_busybox.sh
sh scripts/5_generate_rootfs.sh
sh scripts/6_pack_rootfs.sh
#sh 7_generate_iso.sh
