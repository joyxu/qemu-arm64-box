#!/bin/sh

MESA=$HOME/mesa-debug

export LD_LIBRARY_PATH=$MESA/lib64:$MESA/lib64/aarch64-linux-gnu:$MESA/lib:$MESA/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
export LIBGL_DRIVERS_PATH=$MESA/lib64/dri:$MESA/lib/dri
export VK_ICD_FILENAMES=$MESA/share/vulkan/icd.d/virtio_icd.aarch64.json
export D3D_MODULE_PATH=$MESA/lib64/d3d/d3dadapter9.so.1:$MESA/lib/d3d/d3dadapter9.so.1
export VN_DEBUG=init,result,wsi
