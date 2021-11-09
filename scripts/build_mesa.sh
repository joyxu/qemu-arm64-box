#!/bin/sh

T=~/mesa-debug

sudo apt build-dep mesa

meson build64 --prefix $T -Ddri-drivers= -Dgallium-drivers=radeonsi,swrast,zink,panfrost,virgl -Dvulkan-drivers=amd,virtio-experimental -Dgallium-nine=true -Dosmesa=false -Dbuildtype=debug

sudo ninja -C build64 install
