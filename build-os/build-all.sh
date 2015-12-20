#!/bin/bash
set -ev

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "$SCRIPT_DIR"
mkdir -pv build
cd build

#
# Use Buildroot to compile the system
#

BUILDROOT_VER="2015.11.1"

if [ ! -f download.done ]; then
	wget -nc http://buildroot.uclibc.org/downloads/buildroot-${BUILDROOT_VER}.tar.gz
	> $SCRIPT_DIR/build/download.done
fi

if [ ! -d buildroot-${BUILDROOT_VER} ]; then
    tar xzf buildroot-${BUILDROOT_VER}.tar.gz
fi

if [ ! -f toolchain.done ]; then

	cd buildroot-${BUILDROOT_VER}
    
    # Copy config files
    cp "$SCRIPT_DIR/buildroot-patches/buildroot.config" .config
	cp "$SCRIPT_DIR/buildroot-patches/busybox.config" package/busybox/busybox.config
	cp -r "$SCRIPT_DIR/buildroot-patches/libvlc" package/
	cp -r "$SCRIPT_DIR/buildroot-patches/vlc-qt" package/
	cp -r "$SCRIPT_DIR/buildroot-patches/rpi-car-system" package/
	
	set +e
	patch -f -p 1 < "$SCRIPT_DIR/buildroot-patches/Config.in.patch"
	patch -f -p 1 < "$SCRIPT_DIR/buildroot-patches/qt5.patch"
	set -e

	# Create rpi-car-system sources tarball
	OLD_PWD=$PWD
	cd "$SCRIPT_DIR/.."
	tar --exclude="build" --exclude="*~" --exclude="build-os" --exclude=".git" --exclude="Makefile" --exclude="musicindex-generator/Makefile" --exclude="launcher/Makefile" -zcf "$OLD_PWD/../rpi-car-system-sources.tar.gz" .
	cd "$OLD_PWD"

    make

    # This file is used to check if the system has been built
    > $SCRIPT_DIR/build/toolchain.done
else
    echo "System already built !!!"
fi

SYSTEM_ROOT="${SCRIPT_DIR}/build/buildroot-${BUILDROOT_VER}/output/target"

#
# Copy the official bootloader
#

cd "${SYSTEM_ROOT}/../images/rpi-firmware"

# Copy all files to /boot dir
cp -r bcm2708-rpi-b.dtb bcm2708-rpi-b-plus.dtb bcm2709-rpi-2-b.dtb bootcode.bin start.elf fixup.dat overlays/ ../../target/boot/

# Rename the kernel
cd "${SYSTEM_ROOT}/boot"
set +e
mv zImage kernel.img
set -e

#
# Copy other scripts
#

cd "${SCRIPT_DIR}/scripts"

# 755 for dir
# 754 for executable or scripts
# 644 for config files

#
# Start and stop files
install -d -m 755 "${SYSTEM_ROOT}/etc/rc.d/init.d"
install -d -m 755 "${SYSTEM_ROOT}/etc/rc.d/start"
install -d -m 755 "${SYSTEM_ROOT}/etc/rc.d/stop"
install -m 644 etc/rc.d/init.d/functions "${SYSTEM_ROOT}/etc/rc.d/init.d/"
install -m 754 etc/rc.d/startup          "${SYSTEM_ROOT}/etc/rc.d/"
install -m 754 etc/rc.d/shutdown         "${SYSTEM_ROOT}/etc/rc.d/"
install -m 754 etc/rc.d/init.d/syslog    "${SYSTEM_ROOT}/etc/rc.d/init.d/"
ln -sf ../init.d/syslog "${SYSTEM_ROOT}/etc/rc.d/start/S05syslog"
ln -sf ../init.d/syslog "${SYSTEM_ROOT}/etc/rc.d/stop/K99syslog"

rm ${SYSTEM_ROOT}/etc/inittab
rm ${SYSTEM_ROOT}/etc/fstab

install -m 754 etc/inittab "${SYSTEM_ROOT}/etc/"
install -m 644 etc/fstab "${SYSTEM_ROOT}/etc/"

#
# Boot files
install -m 644 boot/config.txt "${SYSTEM_ROOT}/boot/"
install -m 644 boot/cmdline.txt "${SYSTEM_ROOT}/boot/"

#
# mdev file
install -m 644 etc/mdev.conf "${SYSTEM_ROOT}/etc/"

#
# profile files
rm ${SYSTEM_ROOT}/etc/profile 
install -m 754 etc/profile "${SYSTEM_ROOT}/etc/"
install -m 644 etc/nanorc "${SYSTEM_ROOT}/etc/"

rm ${SYSTEM_ROOT}/etc/group
install -m 644 etc/group "${SYSTEM_ROOT}/etc/"

#
# i18n
install -d -m 755 "${SYSTEM_ROOT}/etc/i18n"
install -m 644 fr-latin9.bmap "${SYSTEM_ROOT}/etc/i18n"

set +e

rm ${SYSTEM_ROOT}/etc/issue
rm ${SYSTEM_ROOT}/etc/os-release
rm ${SYSTEM_ROOT}/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM

set -e

echo \"All scripts installed !\"

#
# Create the final tarball
#

cd ${SYSTEM_ROOT}

# When uncompressing the tarball, make sure to pass tar the "-p" switch to ensure permissions are preserved.
tar -jcf ../../../rpi-car-system.tar.bz2 *

set +v
echo "----------------------------------"
echo "Build Finish !!!!"
echo "----------------------------------"



