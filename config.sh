#!/usr/bin/env bash
set -euo pipefail

# This is the main configuration file that you will edit.
# Also check out two more files: custom.sh and finish-install.sh, you might want to edit them as well.
# (NOTE TO SELF): update custom.sh before install

# This script assumes the following:
# 1. You have Intel CPU
# 2. You have Nvidia GPU
# 3. You have WIFI
# 4. You have Bluetooth
# 5. Your drive is in UEFI mode / GPT partitioning scheme
# 6. Uses RAM for Swap (assuming you have lots of spare RAM)
#
# If any of these are not true - you might need to tweak the script itself for your machine, not just this file.

# Custom variables for my own custom.sh
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
service=(
    docker
    bluetooth
    cronie
    systemd-networkd
    sshd # For development env deployments.
)

user_packages=(
    gvim            # Text editor. GVIM package contains VIM with +clipboard support.
    less            # Tool for limiting terminal output.
    htop            # Tool for pretty resources analysis.
    #steam           # Steam gaming client.
    code            # VS Code.
    discord         # Official Discord client.
    encfs           # Encryption filesystem client for protecting folders.
    gocryptfs       # Better than encfs
    wlsunset        # Control backlight color (warmer at night)

    # KDE PDF reader with many features (consider changing to vi-like one, KDE brings a lot of dependencies).
    # qt6-multimedia-ffmpeg or qt6-multimedia-gstreamer is a dependency of okular, preselect ffmpeg.
    okular qt6-multimedia-ffmpeg

    wireguard-tools     # For connecting home PC to DO docker Swarm.
    freerdp             # RDP client to connect to my Windows laptop.
    ncspot              # Console Spotify client.
    npm                 # NodeJS & NPM.
    libreoffice-fresh   # Office packages.
    ranger              # VI-like file manager.
    mpv                 # Video player.
    imv                 # Image viewer.
    openssh             # Used to connect to SSH servers & generate ssh-keygen.
    telegram-desktop    # Telegram messenger.
    thefuck             # Automatic wrong command fixing.
    tmux                # Terminal multiplexer.
    xournalpp           # Handwritten brainstorming journal. (TODO: alternatively try Lorien: aur lorien-bin package)
    ncdu                # NCurses version of du, to see how much space is taken.
    jellyfin-mpv-shim   # For integrating mpv with jellyfin.
    firefox             # I'm using it in kiosk mode for NitroType typing.

    # Git for development: duplicated here in case we decide we don't need YAY.
    # github-cli is needed for auth credential manager to be able to authenticate (without ssh).
    git github-cli

    # Android phone mounting.
    android-file-transfer   # Usage: aft-mtp-mount ~/mnt

    # .NET development.
    dotnet-sdk-8.0 dotnet-sdk aspnet-runtime-8.0 aspnet-runtime

    # VirtualBox for VDI.
    virtualbox virtualbox-host-modules-arch virtualbox-guest-iso
)

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

flatpak_packages=(
    us.zoom.Zoom
    com.github.IsmaelMartinez.teams_for_linux
    com.slack.Slack
    net.ankiweb.Anki
    app.zen_browser.zen
    com.jetbrains.Rider
)
