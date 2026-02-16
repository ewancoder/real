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
    # === Console utils ===
    android-file-transfer   # Android phone mount: aft-mtp-mount ~/mnt
    cronie rsync    # For backups.
    encfs           # Encryption filesystem client for protecting folders.
    flatpak         # A temporary substitude for some AUR packages.
    freerdp         # RDP client to connect to my Windows laptop.
    gocryptfs       # Better than encfs.
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
    wlsunset        # Control backlight color (warmer at night)
    zsh             # Alternative shell.

    # === Coding & Office ===
    code # VS Code.
    docker docker-compose docker-buildx # For homelab, buildx is needed for Rider debugging.
    dotnet-sdk-8.0 dotnet-sdk aspnet-runtime-8.0 aspnet-runtime aspnet-targeting-pack # .NET development
    firefox # I'm using it in kiosk mode for NitroType typing.
    git # For development.
    libreoffice-fresh # Office packages.
    npm # NodeJS & NPM.
    okular qt6-multimedia-ffmpeg # KDE PFD reader (consider changing to something vi-like), requires qt6-multimedia backend.
    xournalpp # Handwritten brainstorming journal. (TODO: alternatively try Lorien: aur lorien-bin package)

    # === Multimedia ===
    discord             # Official Discord client.
    imv                 # Image viewer.
    jellyfin-mpv-shim   # For integrating mpv with jellyfin.
    mpv                 # Video player.
    ncspot              # Console Spotify client.
    pavucontrol         # GUI volume control.
    smb                 # Samba share for TV screensaver.
    steam               # Steam. Might rely on GPU drivers being installed first. Need to test.
    telegram-desktop    # Telegram messenger.
    # === Unused anymore ===
    # github-cli - needed for auth credential manager to be able to authenticate (without ssh).
    # gnome-keyring - saves passwords for GTK apps: git, github-cli, google-chrome.
    # virtualbox virtualbox-host-modules-arch virtualbox-guest-iso - for work, don't use it now.
)

services+=(
    docker  # All my projects & homelab.
    cronie  # CRON jobs (regular backups).
    sshd    # SSH server.
    smb     # Samba share for TV screensaver.
)

flatpak+=(
    us.zoom.Zoom
    com.github.IsmaelMartinez.teams_for_linux
    com.slack.Slack
    net.ankiweb.Anki
    app.zen_browser.zen
    #com.jetbrains.Rider
)

aur+=(
    uhk-agent-appimage  # UHK agent.
    sptlrx-bin          # Real-time lyrics for Spotify.
)
