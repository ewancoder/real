#!/usr/bin/env bash
set -euo pipefail

packages+=(
    jq              # JSON parsing.
    cronie rsync    # For backups.
    gvim            # Text editor. GVIM package contains VIM with +clipboard support.
    htop            # Tool for pretty resources analysis.
    inetutils       # Needed for 'hostname' command, for backup script to discern different devices.
    less            # Tool for limiting terminal output.
    ncdu            # NCurses version of du, to see how much space is taken.
    openssh         # Used to connect to SSH servers & generate ssh-keygen.
    ranger          # VI-like file manager.
    sbctl           # For signing EFIs for SecureBoot.
    tmux            # Terminal multiplexer.
    wireguard-tools # For connecting home PC to DO docker Swarm.
    docker docker-compose   # For homelab.
    git                     # For development.
    samba                   # Samba share for TV screensaver.
    # x-server for XPlane
    xorg-server xorg-xinit xorg-xrandr
    i3-wm rxvt-unicode aspnet-runtime aria2 fuse3
    webkit2gtk-4.1 # For XPlane installer. (removed 'webkit2gtk' package because it's not in the repo anymore)
    pacman-contrib # For checking updates without touching database (rootless)
)

services+=(
    docker  # All my projects & homelab.
    cronie  # CRON jobs (regular backups).
    sshd    # SSH server.
    smb     # Samba share for TV screensaver.
)
