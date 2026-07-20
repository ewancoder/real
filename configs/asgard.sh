#!/usr/bin/env bash
set -euo pipefail

# To change before install:
ssh_port=50000
wifi_ssid="ssid"
wifi_password="pass"
root_password="pass"    # Leave empty to specify during install.
user_password="pass"    # Leave empty to specify during install.

# Hardcoded settings.
wlan_interface=wlan0
hostname=asgard
swapsize=20
timezone=Asia/Tbilisi
username=tyr
shell=/bin/bash
keymap=dvorak
install=(
    core-system
    cpu-intel
    ew-asgard
    fs-tools # We need btrfs.fsck to remove mkinitcpio warnings.
    gpu-nvidia
    gpu-nvidia-docker
    security
)
loadpackages

personal_scripts=(
    personal.asgard.sh
    claude-code.sh
)

# Script control options.
auto=1
hostinstall=0
aur_install=1   # Install AUR packages.
yay_ask=1       # Ask for confirmation when installing YAY packages.
install_grub=0
install_systemdboot=1
encrypted_root=1
secure_boot=1
uki=1
install_folder=/eal-temp # /tmp/eal means it's in RAM, however RAM is volatile.
install_flatpak=1 # Set it to 0 to completely skip installing flatpak packages.
autologin=0 # Disable autologin for server (no graphical session to protect it).
