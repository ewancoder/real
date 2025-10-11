#!/usr/bin/env bash
set -euo pipefail

mess -t "Mounting volumes"
mess -w "This step is not implemented yet. Please, make sure you mount your root filesystem and all the volumes to /mnt\nYou can safely press enter - we will enter a BASH session. After you mount everything - type 'exit' to exit the bash session and continue script installation."
if [ ! -z $swap_partition ]; then
    mess -w "Make sure to manually format the swap partition: mkswap $swap_partition"
fi
# Allows us to mount all needed volumes manually, and then continue the script by exiting this shell (exit command).
/bin/bash

# Needed to get latest package list from the mirror.
mess -t "Update pacman packages list"
pacman -Syy
if [ $hostinstall -eq 1 ]; then
    # We need to manually populate Arch keyring if installing from another system, and not from Live CD.
    mess "Initializing pacman keyring, because we are installing from another host system."
    pacman-key --init
    pacman-key --populate archlinux
fi

mess -t "Install system"
if [ ! -d /run/shm ]; then
    # Arch install needs this folder, but it doesn't exist on systems like Debian, so we need to create it if it doesn't exist.
    mess "Create /run/shm cause it doesn't exist [for debian systems]"
    mkdir /run/shm
fi

# Install Arch :) After this step your EMPTY system is basically ready.
# base - contains minimal GNU toolset: bash, ls, cp, pacman, systemd, etc
# linux - the kernel itself (/boot/vmlinuz-linux)
# linux-firmware - hardware support, without it most contemporary wifi/network/gpu/etc chips won't work
mess "Install base-system"
pacstrap -K /mnt base linux linux-firmware

# Generate fstab file - this file contains entries of all the volumes we need to mount on bootup.
mess "Generate fstab"
genfstab -U /mnt >> /mnt/etc/fstab

mess -t "Chroot to system"

# TODO: figure out how to bind mount /tmp there and reuse it.
# Copy all other install files to /mnt folder (your new system).
mess "Copy {env,config,peal,firstboot}.sh to /mnt/"
cp {env,config,peal,firstboot}.sh /mnt/

mess "Copy packages and scripts folders to /mnt/"
cp -r packages /mnt/
cp -r scripts /mnt/

# Execute main setup script that is executed as root, in your new system (/mnt).
# All the commands executed in peal.sh are essentially executed in your new system.
mess "Go to arch-chroot and execute peal.sh"
arch-chroot /mnt /peal.sh

# After peal.sh stops execution - we've set up everything.
# Clean up the files (remove them) except for firstboot.sh, which we need to execute after reboot.
mess "Remove files from chroot system"
rm -f /mnt/{env,config,peal}.sh
rm -rf /mnt/packages
rm -rf /mnt/scripts

# Exic eal.sh and give the control back to the entry point (install.sh).
mess "Unmount all within /mnt (unmount installed system)"
umount -R /mnt
if [ $hostinstall -eq 1 ]; then
    mess "Exiting chroot (live-cd -> host system)"
fi
