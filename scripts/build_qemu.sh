#!/bin/sh

./configure --enable-virtfs --enable-opengl --enable-virglrenderer --enable-kvm--enable-modules --enable-vnc --target-list=aarch64--softmmu

make -j && sudo make install
