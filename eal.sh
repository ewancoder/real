#!/usr/bin/env bash
set -euo pipefail

mess -t "Mounting volumes"
mess -w "This step is not implemented yet. Please, make sure you mount your root filesystem and all the volumes to /mnt\nYou can safely press enter - we will enter a BASH session. After you mount everything - type 'exit' to exit the bash session and continue script installation."
/bin/bash

mess -t "Update pacman packages list"
pacman -Syy
if [ $hostinstall -eq 1 ]; then
    mess "Initializing pacman keyring, because we are installing from another host system."
    pacman-key --init
    pacman-key --populate archlinux
fi

mess -t "Install system"
if [ ! -d /run/shm ]; then
    mess "Create /run/shm cause it doesn't exist [for debian systems]"
    mkdir /run/shm
fi

mess "Install base-system"
pacstrap -K /mnt base linux linux-firmware

mess "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

mess -t "Chroot to system"

# TODO: figure out how to bind mount /tmp there and reuse it.
mess "Copy {env,config,peal,finish-install}.sh to /mnt/"
cp {env,config,peal,finish-install}.sh /mnt/

if [ -f custom.sh ]; then
    mess "Copy custom.sh to /mnt/"
    cp custom.sh /mnt/
fi
#cp makepkg.patch /mnt/root/
#mess "Copy root and user scripts to /mnt/root"
#if [ ! "$rootscript" == "" ]; then
#    cp $rootscript /mnt/root
#fi
#for (( i = 0; i < ${#user[@]}; i++ )); do
#    if [ ! "${userscript[$i]}" == "" ]; then
#        cp ${userscript[$i]} /mnt/root
#    fi
#done
#mess "Copy after-build script to /mnt/root"
#cp after.sh /mnt/root

mess "Go to arch-chroot and execute peal.sh"
arch-chroot /mnt /peal.sh

mess "Remove files from chroot system"
rm -f /mnt/{env,config,peal,custom}.sh

mess "Unmount all within /mnt (unmount installed system)"
umount -R /mnt
if [ $hostinstall -eq 1 ]; then
    mess "Exiting chroot (live-cd -> host system)"
fi
