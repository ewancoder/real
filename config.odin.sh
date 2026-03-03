#!/usr/bin/env bash
set -euo pipefail

# To change before install:
crypt_password="pass"
git_work_email="work@email.com"
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

# Other settings (usually don't change).
timezone=Asia/Tbilisi
username=ewancoder
shell=/bin/zsh
keymap=dvorak # Set to 'us' to have a regular keymap.
install=(
    cpu-amd
    gpu-nvidia
    gpu-nvidia-docker
    core-system
    security
    fido
    sway
    ewancoder
    #ewancoder-laptop   # Additional tools for laptop.
)
loadpackages

personal_scripts=(
    personal.ewancoder.sh
    dropbox-sway-install.sh
    mega.sh
    #asus-scar-g17-firmware.sh
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
uki_cmdline="rd.luks.name=uuid=root root=/dev/mapper/root rw"
install_folder=/eal-temp # /tmp/eal means it's in RAM.
install_flatpak=1 # Set it to 0 to completely skip installing flatpak packages.
