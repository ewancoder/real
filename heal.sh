#!/usr/bin/env bash
set -euo pipefail

mess -t "Installing needed software"
if which unsquashfs > /dev/null && which curl > /dev/null; then
    mess "Both squashfs-tools and curl are installed, skipping..."
else
    mess "Install squashfs-tools and curl"
    if which pacman > /dev/null; then
        pacman -Syy
        pacman -S --noconfirm squashfs-tools curl
    elif which apt-get > /dev/null; then
        apt-get update
        apt-get -y install squashfs-tools curl
    else
        mess -w "Package manager is neither 'pacman' nor 'apt-get'. Can't install tools. Please, make sure that 'squashfs-tools' and 'curl' packages are installed before continuing."
    fi
fi

mess -t "Prepare Arch linux ROOTFS"
mkdir -p $install_folder/sfs
if [ ! -f $install_folder/root-image.fs.sfs ]; then
    mess "Download root live-cd image"
    curl -o $install_folder/root-image.fs.sfs "$iso"
fi

mess -t "Prepare chroot-environment"
if [ ! -f $install_folder/sfs/usr/bin/bash ]; then
    mess "Unsquash root live-cd image to $install_folder/sfs"
    rm -rf $install_folder/sfs
    unsquashfs -d $install_folder/sfs root-image.fs.sfs
else
    mess "Root filesystem already exists at $install_folder/sfs"
fi
mess "Mount all needed things to rootfs"
mount -t proc none $install_folder/sfs/proc
mount -t sysfs none $install_folder/sfs/sys
mount -o bind /dev $install_folder/sfs/dev
mount -o bind /dev/pts $install_folder/sfs/dev/pts
mount -o bind /tmp $install_folder/sfs/tmp # For our files to be accessible, although this creates a recursive hole lol.
mount -o bind /run $install_folder/sfs/run

# TODO: Fix this hack, do not hide issues.
# It throws an error when it's already the same file (symlinked/binded).
cp -L /etc/resolv.conf $install_folder/sfs/etc || true

mess -t "Chroot into live-cd environment and execute eal.sh (start regular installation)"
mess "Copy install files to $install_folder/sfs/eal"

cp $install_folder/eal.sh $install_folder/sfs/
cp $install_folder/env.sh $install_folder/sfs/
cp $install_folder/config.sh $install_folder/sfs/
cp $install_folder/peal.sh $install_folder/sfs/
cp $install_folder/firstboot.sh $install_folder/sfs/
cp -r $install_folder/packages $install_folder/sfs/
cp -r $install_folder/scripts $install_folder/sfs/

mess "Chroot into $install_folder/sfs and execute /eal/eal.sh"
chroot $install_folder/sfs /eal.sh

mess -t "Unmount everything"
umount -Rl $install_folder/sfs/run
umount -Rl $install_folder/sfs/tmp
umount -Rl $install_folder/sfs/dev/pts
umount -Rl $install_folder/sfs/dev
umount -Rl $install_folder/sfs/sys
umount -Rl $install_folder/sfs/proc
