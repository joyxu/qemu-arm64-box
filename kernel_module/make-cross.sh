#!/usr/bin/env bash

LINUX_BUILD_DIR=../../kernel-dev.build

j="$(($(nproc) - 2))"
while getopts j: OPT; do
  case "$OPT" in
    'j')
      j="$OPTARG"
    ;;
  esac
done

make -j "$j" -C $LINUX_BUILD_DIR M=$PWD ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- "$@"
