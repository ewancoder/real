#!/usr/bin/env bash
set -euo pipefail

# To change before install:
ssh_port=50000
wifi_ssid="ssid"
wifi_password="pass"
hostname=archpc
root_password="pass"    # Leave empty to specify during install.
user_password="pass"    # Leave empty to specify during install.
swapsize=20             # Swap size in Gigabytes, will be allocated on RAM.
swap_partition=""       # /dev/sdb2 if you want your swap on /dev/sdb2.
swap_file=""            # /swapfile, if you want your swap in /swapfile file.
wlan_interface=wlan0
# !!! change this if you use encrypted fs with UKI
# Replace the "uuid" part with the actual UUID of the hardware disk (blkid nvmeXXX)
uki_cmdline="rd.luks.name=uuid=root root=/dev/mapper/root rw"

# Other settings (usually don't change).
timezone=Asia/Tbilisi
username=ewancoder
shell=/bin/bash
keymap=dvorak
install=(
    cpu-intel
    gpu-nvidia
    gpu-nvidia-docker
    core-system
    security
    fido
    ewancoder-asgard
)
loadpackages

## TODO NOW:
#1. Wrong generation of LUKS cmdline: needs to have the actual UUID of the drive.
#  - yeah, it's missing root id, and so waiting for /dev/mapper/root forever
#  !!! format should be: rd.luks.name=UUID=NAME root=dev/mapper/NAME rw
#2. add whatever's needed to install keyring
#3. should be samba, not smb, in packages
#4. bootctl install:
# running in a chroot, enabling --graceful
# couldn't find EFI system partition, skipping
# (probably cause i didn't mount it though lol)
# 5. first of all, /mnt/data/tyr should symlink to /data/tyr, not /data.
# - second --- !!! those checks are for not creating symlinks like /data/tyr/tyr/tyr/tyr. fix that
# 6. add instructions on what to mount not to forget.
# for server it's:
# - /mnt/media, /mnt/data, /, and /efi
# - cronntab -u ewancoder - hardcoded user in the personal script

personal_scripts=(
    personal.asgard.sh
    security.sh
)

# Script control options.
auto=1 # Automatically install everything. Put 0 here to manually confirm each step.
hostinstall=0 # If 1 - install from already running system, otherwise - livecd.
aur_install=1 # Specify 0 here to skip installing ANY aur packages.
yay_ask=0 # Ask for confirmation when installing YAY packages.
install_grub=0
install_systemdboot=1
encrypted_root=1
secure_boot=1
uki=1
install_folder=/eal-temp # /tmp/eal means it's in RAM.
install_flatpak=1 # Set it to 0 to completely skip installing flatpak packages.
autologin=0 # Disable autologin for server (no graphical session to protect it).
