#!/usr/bin/env bash
set -euo pipefail

# This is the main configuration file that you will edit.
# Also check out custom.sh - you might want to edit (or delete) it too.
# (NOTE TO SELF): update custom.sh before install

# This script assumes the following:
# 1. You have WIFI
# 2. You have Bluetooth
# 3. Your drive is in UEFI mode / GPT partitioning scheme
#
# If any of these are not true - you might need to tweak the script itself for your machine, not just this file.

# Build your own desktop.
install=(
    cpu-intel           # CPU drivers.
    gpu-nvidia          # GPU drivers.
    gpu-nvidia-docker   # GPU drivers support.
    core-system         # Core Arch system.
    sway                # Core Sway UI environment.
    ivanpc              # Personal packages.
)
loadpackages # Loads the packages into the variable.

# WiFi settings.
wifi_ssid="ssid"
wifi_password="pass"

# Custom variables for my own custom.sh.
crypt_password="abc"
git_work_email="work@email.com"

# Swap configuration:
# For partition:
    #swap_partition="/dev/sdx8"
# For file:
    #swap_file="/swap"
    #swap_file_size=64 # In GB.
# For RAM - just leave both of these empty:
swap_partition="" # If you are using a partition - make sure to format it (with mkswap) manually.
swap_file=""
swap_file_size=64

# Common variables
hostinstall=0
ssh_port=58123 # Change this for SSHD deployments.
username=ewancoder
hostname=ivanpc
timezone=Asia/Tbilisi
root_password="qwerty" # Leave empty to specify during install.
user_password="qwerty" # Leave empty to specify during install.
windows_efi_volume="" # Only necessary for multiboot, so that GRUB is able to generate proper config. You do not need to specify it if you're installing GRUB & mounting /boot from the same volume as Windows is on.
wlan_interface=wlan0
shell=/bin/zsh
keymap=dvorak # Set to 'us' to have a regular keymap.
swapsize=20 # Swap size in Gigabytes, will be allocated on RAM.

aur_install=1 # Specify 0 here to skip installing ANY aur packages.
yay_ask=1 # Ask for confirmation when installing YAY packages.
yay_user_packages=(
    #dropbox             # Cloud storage.
    #zoom                # Messaging for work.
    uhk-agent-appimage  # UHK agent.
    #teams-for-linux-bin # Teams (instead of Skype).
    #slack-desktop       # Slack.
    sptlrx-bin          # Real-time lyrics for Spotify.
    #anki-bin            # Anki cards app.
    #zen-browser-bin     # Main browser.
    #rider               # .NET development.
)
