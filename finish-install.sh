#!/usr/bin/env bash
set -euo pipefail

read -p "WiFi password: " password
read -p "Autologin username: " username

# This is the script that is copied to installed system to be ran after reboot.

ln -rsf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

iwctl --passphrase $password station wlan0 connect "skazlojop"
sleep 10

pacman -Syyu
pacman -S nvidia-open steam lib32-nvidia-utils nvidia-container-toolkit --noconfirm

mkdir -p /etc/systemd/system/getty@tty1.service.d
echo """[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $username %I \$TERM
""" > /etc/systemd/system/getty@tty1.service.d/autologin.conf

# TODO manual (for now):
# 1. Change sshd port, permitrootlogin, and passwordauthentication settings.

reboot
