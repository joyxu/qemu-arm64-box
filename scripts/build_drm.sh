#!/bin/sh

T=~/mesa-debug

meson build64 --prefix $T

sudo ninja -C build64 install
