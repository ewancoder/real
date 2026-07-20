#!/usr/bin/env bash
set -euo pipefail

# To change before install:
crypt_password="pass"
git_work_email="work@email.com"
ssh_port=50000
wifi_ssid="ssid"
wifi_password="pass"
root_password="pass"    # Leave empty to specify during install.
user_password="pass"    # Leave empty to specify during install.

# Hardcoded settings.
wlan_interface=wlan0
hostname=odin
swapsize=20
timezone=Asia/Tbilisi
username=ewancoder
shell=/bin/zsh
keymap=dvorak
install=(
    audio
    core-system
    cpu-amd
    ew-odin
    fido
    fs-tools
    gpu-nvidia
    security
    sway
    #ew-thor-tools # ADDITIONAL tools for laptop.
)
loadpackages

personal_scripts=(
    personal.odin.sh
    dropbox-sway-install.sh
    mega.sh
    claude-code.sh
    #asus-scar-g17-firmware.sh
)

# Script control options.
auto=1
hostinstall=0
aur_install=1
yay_ask=0
install_grub=0
install_systemdboot=1
encrypted_root=1
secure_boot=1
uki=1
install_folder=/eal-temp # /tmp/eal means it's in RAM.
install_flatpak=1 # Set it to 0 to completely skip installing flatpak packages.
autologin=1
