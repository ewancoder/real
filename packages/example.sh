#!/usr/bin/env bash
set -euo pipefail

# Example of a packages profile.

# Installed during system install (pacman).
packages+=(
    flatpak
    freerdp
)

# Installed after reboot and first boot up.
firstboot_packages+=(
    nvidia-open
    lib32-nvidia-utils
)

# Enabled as systemd service.
services+=(
    docker
    sshd
)

# Installed using flatpak globally in the system.
flatpak+=(
    us.zoom.Zoom
    com.slack.Slack
)

# AUR packages, installed using YAY.
aur=(
    uhk-agent-appimage
    sptlrx-bin
)
