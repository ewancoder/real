#!/usr/bin/env bash
set -euo pipefail

# These packages are required to run a minimal console OS with the following:
# 1. GRUB bootloader on EFI drive
# 2. WiFi network capabilities: iwd
# 3. Common tools: sudo, unzip
# 3. Filesystem tools: btrfs, ntfs-3g
# 4. Sound support
# 5. Bluetooth support

# The following might be refactored away in future, when we update the script:
# 6. YAY for installing AUR packages

packages+=(
    # GRUB bootloader:
    # - efibootmgr is needed to see EFI volumes.
    # - os-prober is needed to generate entry for Windows (if it's installed).
    grub efibootmgr os-prober

    iwd     # Network daemon to be able to connect to Wi-Fi.
    sudo    # SUDO to be able to run sudo by a user.
    unzip   # Archives management. For now I only needed to unzip. Will add others here later.
    btrfs-progs # Utility to manage BTRFS filesystem. Might be handy to manipulate drives live.
    ntfs-3g     # NTFS driver.
   
    # Sound system.
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack
    playerctl   # In order to be able to control players with multimedia keys, systemwide.

    # Bluetooth support.
    bluez bluez-utils

    # Needed to run YAY / makepkg.
    base-devel git
)

services+=(
    bluetooth
    systemd-networkd
)
