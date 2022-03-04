#!/bin/sh

T=~/mesa-debug

git clone https://gitlab.freedesktop.org/virgl/virglrenderer.git

cd virglrenderer
meson build64 -Dvenus-experimental=true --prefix $T

sudo ninja -C build64 install
