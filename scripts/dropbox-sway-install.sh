#!/usr/bin/env bash
set -euo pipefail

# This script installs Dropbox for user $username.
# It is started with the Sway session.

cd /home/$username
curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
chown -R $username:$username /home/$username/.dropbox-dist

# Add starting dropbox with the session if not added yet.
if [ ! -f /home/$username/.config/sway/config ]; then
    mkdir -p /home/$username/.config/sway
    cp /etc/sway/config /home/$username/.config/sway/config
fi
cat /home/$username/.config/sway/config | grep -q dropboxd || echo "exec ~/.dropbox-dist/dropboxd" >> /home/$username/.config/sway/config
chown $username:$username /home/$username/.config
chown $username:$username /home/$username/.config/sway
chown $username:$username /home/$username/.config/sway/config
