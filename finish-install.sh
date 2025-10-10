#!/usr/bin/env bash
set -euo pipefail

# The variables are substituted automatically from config.
after_reboot_packages=()
wifi_ssid=''
wifi_password=''
username=''

# Link resolv.conf for internet DNS to work.
ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Connect to wifi and remember the network.
iwctl --passphrase "$wifi_password" station wlan0 connect "$wifi_ssid"
echo "Waiting for internet connection for 10 seconds..."
sleep 10

# Install after-reboot packages.
if [ ${#after_reboot_packages[@]} -gt 0 ]; then
    echo "Installing packages"
    pacman -Syyu
    pacman -S $after_reboot_packages --noconfirm
fi

# Setup autologin for the user.
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo """[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $username %I \$TERM
""" > /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Delete this script.
rm /finish-install.sh

echo "All done!"
reboot
