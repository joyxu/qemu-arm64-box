#!/bin/sh

T=/home/joyx/mesa-debug

mkdir -p $T
mount -t 9p -o trans=virtio,version=9p2000.L hostshare $T

cd $T
source mesa_env.sh

