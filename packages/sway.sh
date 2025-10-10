#!/usr/bin/env bash
set -euo pipefail

# My sway desktop profile.
# Contains only the bare bones packages to make the system functional,
# without any extra user software.
#
# It uses:
# fuzzel - for launching apps
# foot - as a terminal
# mako - to show notifications
# slurp/grim/swappy - for screenshotting
# noto-fonts - for main fonts

packages+=(
    # Main low-level wayland/system libs.
    wlroots0.19             # Wayland composer, dependency for many WMs.
    xdg-desktop-portal-gtk  # Needed for flatpak apps to talk to Wayland (like opening links from Zoom).
    xdg-desktop-portal-wlr  # Abitily to share screens with wlroots compositor, uses slurp to select a screen.
    wl-clipboard            # Wayland clipboard support
    libnotify               # Notification subsystem (0se notify-send). Used by apps to send notifications.
    xorg-xwayland           # Support for X apps under Wayland.
    qt5-wayland qt6-wayland # Wayland support for QT apps.

    # Sway and core utils. Without these packages some UI features might not work.
    sway        # Main WM.
    swaybg      # Background for Sway.
    swaylock    # For locking the session/screens.
    fuzzel      # Application launcher.
    foot        # Terminal for Wayland.
    mako        # Notification daemon (shows notifications in Wayland).
    # Screenshotting tools.
    # - slurp is used to select part of the screen and output to stdout (and to select a monitor to screen share).
    # - grim is used to screenshot the selected part (or whole monitor) and output to file (or pipe).
    # - wl-clipboard is used to manage clipboard in Wayland (and pipe grim output to it).
    # - swappy is used to edit screenshots inline
    slurp grim swappy
    # Fonts
    # - noto-fonts - the base, the main font that's preferably being used for everything
    # - otf-font-awesome is needed for swappy (screenshotting tool)
    # - noto-fonts-emoji is needed for icons (turtle icon for downloads, Telegram icons on notifications)
    # - google chrome needs ttf-liberation
    noto-fonts ttf-liberation otf-font-awesome noto-fonts-emoji
)
