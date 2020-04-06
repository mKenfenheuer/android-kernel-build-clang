# android-kernel-build-clang
This is a collection of tools to build and android kernel using clang

What to do?
* clone this repo
* edit .gitmodules to reflect the kernel sources repo
* run `git submodule update --init --remote` to make sure all submodules and required tools are available
* build the kernel using `bash build.sh [OPTIONS]` see below for usage
* outputs will be found in build output folder

## Build.sh usage
    bash build.sh [OPTIONS]
    
    Options:
    --kernel    Builds the kernel Image
    --boot_img  Builds a boot.img using the boot img in stock_data
    --zip       Builds a flashable zip file for TWRP and others using anykernel script
    --dtbo      Builds a dtbo.img file for device tree overlays
    --clean     Makes sure to perform a clean build
