#!/bin/sh

sudo apt install build-essential libepoxy-dev libdrm-dev libgbm-dev libx11-dev libvirglrenderer-dev

./configure --enable-virtfs --enable-opengl --enable-virglrenderer --enable-kvm --enable-modules --enable-vnc --target-list=aarch64-softmmu

make -j && sudo make install
