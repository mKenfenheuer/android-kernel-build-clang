#!/bin/bash
exec > >(tee -i build.log)
exec 2>&1
set -x

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export TOOLCHAIN_DIR=$(pwd)/tools/toolchain
export KERNEL_SOURCE_DIR=$(pwd)/kernel_source/
export AIK_DIR=$(pwd)/tools/AIK-Linux/
export DTC_DIR=$(pwd)/tools/prebuilts/linux-x86/dtc
export PREBUILTS_DIR=$(pwd)/tools/prebuilts/
export ANDROID_RELEASE_BRANCH=android-9.0.0_r53
export STOCK_DATA_DIR=$(pwd)/stock_data/
export FLASH_ZIP_DIR=$(pwd)/tools/flash-zip/
export MKDTBOIMG_DIR=$(pwd)/tools/mkdtboimg/
export TARGET_IMAGES_DIR=$(pwd)/build/
export CLANG_DIR=$(pwd)/tools/clang-linux-x86/
export CLANG_VERSION=clang-4691093
export PATH=$TOOLCHAIN_DIR/bin/:$CLANG_DIR/$CLANG_VERSION/bin:$MKDTBOIMG_DIR:$AIK_DIR:$PATH
export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-android-
export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-gnu/lib64
export OPPO_TARGET_DEVICE=MSM_19781
export TARGET_PRODUCT=msmnile
export DEFCONFIG=vendor/sm8150-perf_defconfig
#export DEFCONFIG=defconfig
export DTC_EXT=$DTC_DIR/dtc

clean() {

#make sure submodules are initialized
#git submodule update --init --remote --recursive

#make sure that sh files in AIK dir are executable
chmod +x $AIK_DIR/*.sh

#make sure that sh files in AIK dir are executable
chmod +x $MKDTBOIMG_DIR/*.py

#clean AIK Dir
bash $AIK_DIR/cleanup.sh

#extract boot image
cd $STOCK_DATA_DIR
gzip -f -c -d boot.img.gz > boot.img

#switch to the right branch of toolchain
cd $TOOLCHAIN_DIR
git checkout $ANDROID_RELEASE_BRANCH -f

#switch to the right branch of toolchain
cd $CLANG_DIR
git checkout $ANDROID_RELEASE_BRANCH -f

#switch to the right branch of prebuilts
cd $PREBUILTS_DIR
git checkout $ANDROID_RELEASE_BRANCH -f

#make sure build output dir exists 
mkdir -p $TARGET_IMAGES_DIR

cd $KERNEL_SOURCE_DIR

#clean build resources
make clean O=out
make mrproper O=out
make $DEFCONFIG O=out

}


build() {

#build kernel
cd $KERNEL_SOURCE_DIR
make -j$(nproc --all) O=out CC=clang CLANG_TRIPLE=aarch64-linux-gnu-

}

build_boot() {

#unpack stock image
cd $AIK_DIR
./unpackimg.sh $STOCK_DATA_DIR/boot.img

#replace kernel in unpacked stock image
cp $KERNEL_SOURCE_DIR/out/arch/arm64/boot/Image-dtb ./split_img/boot.img-zImage

#repack stock image
./repackimg.sh

#make sure build out dir is existing
mkdir -p $TARGET_IMAGES_DIR

#copy new boot img to target dir
cp image-new.img $TARGET_IMAGES_DIR/boot.img

}

build_dtbo() {

#make sure build output dir exists 
mkdir -p $TARGET_IMAGES_DIR

rm $TARGET_IMAGES_DIR/dtbo.img

#make dtbo.img
cd $KERNEL_SOURCE_DIR/out/arch/arm64/boot
mkdtboimg.py create dtbo.img dts/*/*.dtbo

#copy new dtbo img to target dir
cp dtbo.img $TARGET_IMAGES_DIR/dtbo.img

}

build_zip() {


#make sure build output dir exists 
mkdir -p $TARGET_IMAGES_DIR

rm $TARGET_IMAGES_DIR/*.zip

#copy files to flashing zip
cp $KERNEL_SOURCE_DIR/out/arch/arm64/boot/Image-dtb $FLASH_ZIP_DIR/Image-dtb
cp $KERNEL_SOURCE_DIR/out/arch/arm64/boot/dtbo.img $FLASH_ZIP_DIR/dtbo.img

#create flashable zip
cd $FLASH_ZIP_DIR
zip $TARGET_IMAGES_DIR/realme-x2pro-kernel-$(date +"%Y%m%d_%H%M%S").zip -r ./

}

#clean previous builds
for i in "$@" ; do
    if [[ $i == "--clean" ]] ; then
        echo "Cleaning."
	clean
	break
    fi
done

#measure time
start=`date +%s`

#build kernel
for i in "$@" ; do
    if [[ $i == "--kernel" ]] ; then
        echo "Building Kernel."
	time build
	break
    fi
done

#build boot image
for i in "$@" ; do
    if [[ $i == "--boot_img" ]] ; then
        echo "Building Boot Image."
        time build_boot
        break
    fi
done

#build dtbo image
for i in "$@" ; do
    if [[ $i == "--dtbo" ]] ; then
        echo "Building DTBO Image."
        time build_dtbo
        break
    fi
done


#build flashable zip
for i in "$@" ; do
    if [[ $i == "--zip" ]] ; then
        echo "Building Flashable Zip File."
        time build_zip
        break
    fi
done

end=`date +%s`
runtime=$((end-start))

echo $runtime
