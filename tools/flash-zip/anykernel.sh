# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Android Kernel
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=RMX1931
device.name2=RMX1931CN
device.name3=rmx1931
device.name4=rmx1931cn
device.name5=rmx1931CN
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=none;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
dump_boot;

# begin ramdisk changes



# end ramdisk changes

write_boot;
## end install

