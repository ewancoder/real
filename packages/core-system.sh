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
    # TODO: remove unnecessary packages from here when using systemd-boot.
    grub efibootmgr os-prober

    iwd     # Network daemon to be able to connect to Wi-Fi.
    # TODO: remove sudo when using run0.
    sudo    # SUDO to be able to run sudo by a user.
    # TODO: Consider removing this when not needed.
    unzip   # Archives management. For now I only needed to unzip. Will add others here later.
    btrfs-progs # Utility to manage BTRFS filesystem. Might be handy to manipulate drives live.
    # TODO: Consider removing this when not needed.
    ntfs-3g     # NTFS driver.
   
    # TODO: This whole section can be completely removed from the server.
    # Sound system.
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack
    playerctl   # In order to be able to control players with multimedia keys, systemwide.

    # TODO: I also do not need bluetooth on the server.
    # Bluetooth support.
    bluez bluez-utils

    # TODO: We might not even need yay/makepkg on the server.
    # Needed to run YAY / makepkg.
    base-devel git
)

# TODO: Remove bluetooth if we remove it from the above list.
services+=(
    bluetooth
    systemd-networkd
)
