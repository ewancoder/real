#!/usr/bin/env bash
set -euo pipefail

echo "Performing after-install setup"
# The variables are substituted automatically from config.
firstboot_packages=()
flatpak=()
wifi_ssid=''
wifi_password=''
username=''
install_flatpak=1

# Link resolv.conf for internet DNS to work.
ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Connect to wifi and remember the network.
echo "Connecting to the internet... (10s)"
iwctl --passphrase "$wifi_password" station wlan0 scan on
sleep 5
iwctl --passphrase "$wifi_password" station wlan0 connect "$wifi_ssid"
sleep 5

# Install after-reboot packages.
if [ ${#firstboot_packages[@]} -gt 0 ]; then
    echo "Installing packages"
    pacman -Syyu
    pacman -S $firstboot_packages --noconfirm
fi

if [ "${#flatpak[@]}" -gt 0 ] && [ $install_flatpak -eq 1 ]; then
    echo "Installing flatpak packages"
    # If flatpak packages exist in config - install them.
    # This will only work if flatpak itself was installed in the system.
    # (one of the packages in config should be flatpak)
    echo "Install Flatpak packages"
    sudo pacman -S --noconfirm flatpak
    sudo flatpak install ${flatpak[@]} --noninteractive --system
else
    echo "Skip installing Flatpak packages."
fi

# Change autologin for the user instead of the root.
sed -i "s/root/$username/g" /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Delete this script.
sed -i '/firstboot.sh/d' /root/.bash_profile
rm /firstboot.sh

# Reboot again.
echo "All done!"
reboot
