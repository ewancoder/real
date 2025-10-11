#!/usr/bin/env bash
set -euo pipefail

# This script assumes the following:
# 1. You have WIFI
# 2. You have Bluetooth
# 3. Your drive is in UEFI mode / GPT partitioning scheme
#
# If any of these are not true - you might need to tweak the script itself for your machine, not just this file.

# Custom variables for my personal.ewancoder.sh script, can be deleted completely.
crypt_password="abc"
git_work_email="work@email.com"

# WiFi settings.
wifi_ssid="ssid"
wifi_password="pass"
wlan_interface=wlan0

# Device-specific settings.
hostname=ivanpc         # Should be unique per device on the same network.
root_password="qwerty"  # Leave empty to specify during install.
user_password="qwerty"  # Leave empty to specify during install.
ssh_port=58123          # Change this for SSHD deployments.
windows_efi_volume=""   # Specify if it's different from your linux EFI partition, for GRUB config generation.
swap_partition=""       # /dev/sdb2 if you want your swap on /dev/sdb2.
swap_file=""            # /swapfile, if you want your swap in /swapfile file.
swapsize=20             # Swap size in Gigabytes, will be allocated on RAM.

# Other settings (usually don't change).
timezone=Asia/Tbilisi
username=ewancoder
shell=/bin/zsh
keymap=dvorak # Set to 'us' to have a regular keymap.

# Packages: build your own desktop.
install=(
    cpu-intel           # CPU drivers.
    gpu-nvidia          # GPU drivers.
    gpu-nvidia-docker   # GPU drivers support.
    core-system         # Core Arch system.
    sway                # Core Sway UI environment.
    ewancoder           # Personal packages shared across devices.
)
loadpackages # Loads the packages into the variable.

# These scripts are running in this order at the end of installation.
personal_scripts=(
    personal.ewancoder.sh
)

# Script control optoins.
auto=1 # Automatically install everything. Put 0 here to manually confirm each step.
hostinstall=0 # If 1 - install from already running system, otherwise - livecd.
aur_install=1 # Specify 0 here to skip installing ANY aur packages.
yay_ask=1 # Ask for confirmation when installing YAY packages.
install_grub=1
