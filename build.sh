#!/bin/bash
export ARCH=arm64
export SUBARCH=arm64
export TOOLCHAIN_DIR=$(pwd)/tools/toolchain
export KERNEL_SOURCE_DIR=$(pwd)/kernel_source/
export AIK_DIR=$(pwd)/tools/AIK-Linux/
export STOCK_DATA_DIR=$(pwd)/stock_data/AIK-Linux/
export MKDTBOIMG_DIR=$(pwd)/tools/mkdtboimg/
export TARGET_IMAGES_DIR=$(pwd)/build/
export CLANG_FOLDER=$(pwd)/tools/clang-linux-x86/clang-r365631c/
export PATH=$TOOLCHAIN_DIR/bin/:$CLANG_FOLDER/bin:$MKDTBOIMG_DIR:$AIK_DIR:$PATH
export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-android-
export OPPO_TARGET_DEVICE=MSM_19781
export TARGET_PRODUCT=msmnile


#make sure that sh files in AIK dir are executable
chmod +x $AIK_DIR/*.sh

#clean AIK Dir
bash $AIK_DIR/cleanup.sh

#extract boot image
cd $STOCK_DATA_DIR
gumzip boot.img.gz

cd $KERNEL_SOURCE_DIR

#clean build resources
make clean O=out
make mrproper O=out
make defconfig O=out

#build kernel
make -j$(nproc --all) O=out CC=clang CLANG_TRIPLE=aarch64-linux-gnu-

#unpack stock image
cd $AIK_DIR 
./unpackimg.sh $STOCK_DATA_DIR/boot.img

#replace kernel in unpacked stock image 
cp $KERNEL_SOURCE_DIR/out/arch/arm64/boot/Image ./split_img/boot.img-zImage

#repack stock image
./repackimg.sh

#make sure build out dir is existing
mkdir -p $TARGET_IMAGES_DIR

#copy new boot img to target dir
cp image-new.img $TARGET_IMAGES_DIR/boot.img

#make dtbo.img 
cd $KERNEL_SOURCE_DIR/out/arch/arm64/boot
python mkdtboimg.py create dtbo.img dts/*/*.dtbo

#copy new dtbo img to target dir
cp dtbo.img $TARGET_IMAGES_DIR/dtbo.img

