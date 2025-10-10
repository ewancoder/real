#!/usr/bin/env bash
set -euo pipefail

echo "Performing after-install setup"
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

# Change autologin for the user instead of the root.
sed -i "s/root/$username/g" /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Delete this script.
sed -i '/firstboot.sh/d' /root/.bash_profile
rm /firstboot.sh

# Reboot again.
echo "All done!"
reboot
