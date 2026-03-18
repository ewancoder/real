#!/usr/bin/env bash
set -euo pipefail

packages+=(
    jq # json parsing
    cronie rsync    # For backups.
    gvim            # Text editor. GVIM package contains VIM with +clipboard support.
    htop            # Tool for pretty resources analysis.
    inetutils       # Needed for 'hostname' command, for backup script to discern different devices.
    less            # Tool for limiting terminal output.
    ncdu            # NCurses version of du, to see how much space is taken.
    net-tools       # For ifconfig for script that shows status of downloads/uploads.
    openssh         # Used to connect to SSH servers & generate ssh-keygen.
    ranger          # VI-like file manager.
    sbctl           # For signing EFIs for SecureBoot.
    tmux            # Terminal multiplexer.
    wireguard-tools # For connecting home PC to DO docker Swarm.
    docker docker-compose   # For homelab.
    git                     # For development.
    samba                   # Samba share for TV screensaver.
    adguardhome
    # x-server for XPlane
    xorg-server xorg-xinit xorg-xrandr
    i3-wm rxvt-unicode aspnet-runtime aria2 fuse3
    lvm2 # For lvm.
)

services+=(
    docker  # All my projects & homelab.
    cronie  # CRON jobs (regular backups).
    sshd    # SSH server.
    smb     # Samba share for TV screensaver.
)
