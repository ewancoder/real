#!/usr/bin/env bash
set -euo pipefail

# These packages are required to run a minimal console OS with WiFi and Bluetooth.
# Packages excluded in the latest revision:
# 1. sudo - using run0 instead; however we might still need sudo for scripts / makepkg
# 2. grub - using systemd-boot instead

packages+=(
    iwd                 # WiFi
    bluez bluez-utils   # Bluetooth
)

# TODO: Remove bluetooth if we remove it from the above list.
services+=(
    bluetooth
    systemd-networkd
)
