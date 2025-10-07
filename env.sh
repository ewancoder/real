#!/usr/bin/env bash
set -euo pipefail
step=

title="Ewancoder Arch Linux (EAL) installation script"
version="3.0: Rad / Rewritten / Refactored / Really-simplified / R-EAL"

# Where to place everything.
# If installing from another host system - should have 2Gb available space.
install_folder=/tmp/eal

# Install from within already running OS. Using hostinstall=1 you can
# install Arch linux from any other distribution (like Debian), and even
# (possibly) from BSD, MacOS, Windows, <any other> operating systems.
#
# This mode uses *chroot* to log into minimal root live cd ($iso),
# installation then proceeds under this *chroot* inside another *chroot*.
#
# So basically, if you can get chroot working inside your OS, you should be
# able to install Arch linux with this script right away.
hostinstall=1

# Path to Arch linux rootfs (minimal live-cd) *.fs.sfs image needed for
# installation from within running OS ($hostinstall=1).
iso="https://mirror.telepoint.bg/archlinux/iso/$(date +%Y.%m.01)/arch/x86_64/airootfs.sfs"

# Fully automatic install, pause only if error occurs. If $auto=0, the
# script will pause before each step and ask you to confirm execution of
# this step by pressing [RETURN].
auto=1

# Show each executed command and values of used variables.
verbose=1

# Substitute all variables with their values in verbose mode.
#
# If $substitute=0, verbose output shows variables like variables (e.g.
# 'echo something > $filename').
# If $substitute=1, verbose output shows variable values instead of
# the variables itself (e.g. 'echo something > myfile').
# EDIT: Substitution is BROKEN for now, do not use it.
#substitute=1

# This value indicates how much seconds to wait until trying repeating
# failed command automatically.
# If value is 0, there's no timeout and script will wait forever or until
# user intervenes.
timeout=0

# Make it a 1 if you want the script to fail during some errors.
# Error handling won't work properly, but you'll make sure nothing gets executed after the error occurs.
# Leave at 0 for our custom error handling to properly work.
extra_safe=0

# PC hostname. In will be discoverable in local network.
hostname=archpc

# Local timezone. You can find list of time zones by issuing
# `timedatectl list-timezones` command. Also, you can search for it in
# /usr/share/zoneinfo folder.
timezone=Europe/London

# All needed locales. System locale is the first one.
locale=( en_US.UTF-8 )

# Packages that are essential for the system to work (WM-agnostic): drivers, utils, etc.
special_packages=(
    intel-ucode # Intel CPU security patches, for AMD use amd-ucode.
    #nvidia-open # Nvidia open-source latest proprietary drivers.

    # GRUB bootloader:
    # - efibootmgr is needed to see EFI volumes.
    # - os-prober is needed to generate entry for Windows (if it's installed).
    grub efibootmgr os-prober

    sudo    # SUDO to be able to run sudo by a user.
    iwd     # Network daemon to be able to connect to Wi-Fi.

    # Needed to be able to build YAY (can be uninstalled later I guess?).
    base-devel git go

    # Sound system.
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack

    # Bluetooth support.
    bluez bluez-utils

    # Docker. Script enables it later so we need it here not to break it.
    # If you do not need docker - remove it from here and from below.
    # buildx is needed for Rider docker debug
    docker docker-compose docker-buildx

    playerctl   # In order to be able to control players with multimedia keys, systemwide.

    unzip       # Archives management. For now I only needed to unzip. Will add others here later.

    btrfs-progs # Utility to manage BTRFS filesystem. Might be handy to manipulate drives live.
    ntfs-3g     # NTFS driver.
)

# Essential packages for a working WM environment.
essential_packages=(
    wlroots                 # Wayland composer, dependency for many WMs.
    xdg-desktop-portal-wlr  # Abitily to share screens with wlroots compositor, uses slurp to select a screen.
    gnome-keyring           # Ability to save passwords for GTK apps (like Skype).
    swaybg  # Background for Sway.
    swaylock # For locking the session/screens.
    fuzzel  # Application launcher.

    # Screenshotting tools.
    # - slurp is used to select part of the screen and output to stdout (and to select a monitor to screen share).
    # - grim is used to screenshot the selected part (or whole monitor) and output to file (or pipe).
    # - wl-clipboard is used to manage clipboard in Wayland (and pipe grim output to it).
    # - swappy is used to edit screenshots inline
    slurp grim wl-clipboard swappy

    # Fonts (TODO: figure out which ones I need).
    # - otf-font-awesome is needed for swappy
    # - noto-fonts-emoji is needed for icon (turtle icon for downloads, Telegram icons on notifications)
    noto-fonts ttf-liberation otf-font-awesome noto-fonts-emoji

    pavucontrol # GUI audio manager.
    sway        # Main WM.
    foot        # Terminal for Wayland.
    libnotify   # Notification subsystem (use notify-send).
    mako        # Notification daemon (shows notifications in Wayland).
    net-tools   # For ifconfig for script that shows status of downloads/uploads.

    qt5-wayland qt6-wayland # Wayland support for QT apps.
    xorg-xwayland           # Support for X apps under Wayland.
    cronie rsync            # For backups.
    zsh                     # Alternative shell.
    inetutils               # Needed for 'hostname' command, for backup script to discern different devices.
)

# Additional user software.
user_packages=( )
yay_user_packages=( )
yay_ask=1 # Ask for confirmation when installing yay packages.

# Color constants.
Green=$(tput setaf 2)
Yellow=$(tput setaf 3)
Red=$(tput setaf 1)
Blue=$(tput setaf 6)
Bold=$(tput bold)
Def=$(tput sgr0)

# Message function - neat output.
mess() {
    if [ -f /var/lib/pacman/db.lck ]; then
        # Need this in case pacman is still locked from last operation.
        # This happens when installing on SSD (very fast).
        rm -f /var/lib/pacman/db.lck
    fi

    # If the first argument has pattern like "-o" or "-w" - it is an option.
    if [[ "$1" == -? && "${#1}" -eq "2" ]]; then
        m=$2
        o=$1
    else
        m=$1
        o=""
    fi

    # Stylize message.
    case $o in
        # Pause. Notifies the user that manual interaction is required.
        "-p")
            Style="$Bold$Yellow\n-> $m [MANUAL]$Def"
            step=$m
            ;;
        # Warning. Shows up as bright red exclamation sign. Pauses even in auto mode.
        "-w")
            Style="\n$Bold$Red! $m$Def"
            ;;
        # Title. Huge delimited and spaced area. Does NOT pause even in non-auto mode.
        "-t")
            Line="$(printf "%$(tput cols)s\n"|tr ' ' '-')"
            Style="\n$Line$Bold$Green\n-> $m$Def\n$Line"
            step=$m
            ;;
        # Same as warning, but inline. Also doesn't pause.
        "-q")
            Style="$Bold$Red$m$Def"
            ;;
        # MAGIC. Only used for script generation - prints executed commands with their variable values.
        "-v")
            Style="$Blue-> $m$Def"
            echo "$m" | grep -oP '(?<!\[)\$[{(]?[^"\s\/\047.\\]+[})]?' | uniq > /tmp/eal-vars || true
            if [ ! "$(cat /tmp/eal-vars)" == "" ]; then
                while read -r p; do
                    value=$(eval echo "$p")
                    Style=$(echo -e "$Style\n\t$Green$p = $value$Def")
                done < /tmp/eal-vars
            fi
            rm /tmp/eal-vars
            ;;
        # Regular message.
        *)
            Style="$Bold$Green\n-> $Def$Bold$m$Def"
            step=$m
            ;;
    esac

    # Print message.
    if [ "$o" == "-v" ]; then
        echo -en "$Style\n"
    elif [ "$o" == "-p" ]; then
        echo -en "$Style"
        read -r
    else
        echo -e "$Style"
        if ([ "$o" == "-w" ] || [ "$o" == "-p" ]) ||
            ([ "$o" == "" ] && [ $auto -eq 0 ]); then
            read -rp "$Bold${Yellow}Continue [ENTER]$Def"
        fi
    fi
}
