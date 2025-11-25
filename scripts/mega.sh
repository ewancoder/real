#!/usr/bin/env bash
set -euo pipefail

# This script installs MEGASync for user $username.
# It is started with the Sway session.

cd /home/$username
curl https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst -o megapkg
pacman -U "$PWD/megapkg"
rm megapkg

# Add starting megasync with the session if not added yet.
if [ ! -f /home/$username/.config/sway/config ]; then
    mkdir -p /home/$username/.config/sway
    cp /etc/sway/config /home/$username/.config/sway/config
fi
cat /home/$username/.config/sway/config | grep -q megasync || echo "exec megasync" >> /home/$username/.config/sway/config
chown $username:$username /home/$username/.config
chown $username:$username /home/$username/.config/sway
chown $username:$username /home/$username/.config/sway/config
