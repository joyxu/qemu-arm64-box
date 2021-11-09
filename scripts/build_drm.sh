#!/bin/sh

T=~/mesa-debug

sudo apt install meson

meson build64 --prefix $T

sudo ninja -C build64 install
