#!/bin/bash
export ARCH=arm64
export SUBARCH=arm64
export TOOLCHAIN_DIR=$(pwd)/tools/toolchain
export KERNEL_SOURCE_DIR=$(pwd)/kernel_source/
export AIK_DIR=$(pwd)/tools/AIK-Linux/
export STOCK_DATA_DIR=$(pwd)/stock_data/
export MKDTBOIMG_DIR=$(pwd)/tools/mkdtboimg/
export TARGET_IMAGES_DIR=$(pwd)/build/
export CLANG_FOLDER=$(pwd)/tools/clang-linux-x86/clang-r365631c/
export PATH=$TOOLCHAIN_DIR/bin/:$CLANG_FOLDER/bin:$MKDTBOIMG_DIR:$AIK_DIR:$PATH
export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-android-
export OPPO_TARGET_DEVICE=MSM_19781
export TARGET_PRODUCT=msmnile

#make sure submodules are initialized
git submodule update --init --recursive

#make sure that sh files in AIK dir are executable
chmod +x $AIK_DIR/*.sh

#make sure that sh files in AIK dir are executable
chmod +x $MKDTBOIMG_DIR/*.py

#clean AIK Dir
bash $AIK_DIR/cleanup.sh

#extract boot image
cd $STOCK_DATA_DIR
gzip -f -c -d boot.img.gz > boot.img

#switch to android10-gsi branch of toolchain
cd $TOOLCHAIN_DIR
git checkout android10-gsi

cd $KERNEL_SOURCE_DIR

#clean build resources
make clean O=out
make mrproper O=out
make defconfig O=out
