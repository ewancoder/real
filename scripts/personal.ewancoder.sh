#!/usr/bin/env bash
set -euo pipefail

dotfiles_repo="ewancoder/dotfiles"

# Fix failing rutracker dns.
echo "104.21.32.39 rutracker.org" > /etc/hosts

# Restore symlinks to mnt.
mkdir -p /mnt/data/home/{projects,.var}
mkdir -p /mnt/data/{Dropbox,cloud}
mkdir -p /mnt/data/security/{ssh,gnupg,sbctl}
chown $username:$username /mnt/data/home
chown $username:$username /mnt/data/home/{projects,.var}
chown $username:$username /mnt/data/Dropbox
chown $username:$username /mnt/data/security/{ssh,gnupg}
[ ! -e /home/$username/projects ] && ln -fs /mnt/data/home/projects /home/$username/projects
[ ! -e /home/$username/.var ] && ln -fs /mnt/data/home/.var /home/$username/.var
[ ! -e /home/$username/Dropbox ] && ln -fs /mnt/data/Dropbox /home/$username/Dropbox
[ ! -e /home/$username/.ssh ] && ln -fs /mnt/data/security/ssh /home/$username/.ssh
[ ! -e /home/$username/.gnupg ] && ln -fs /mnt/data/security/gnupg /home/$username/.gnupg
mv /var/lib/sbctl /var/lib/sbctl_backup || true
ln -fs /mnt/data/security/sbctl /var/lib/sbctl

# Change default SSH port, disable Password auth and Root login.
sed -i "s/^#\?Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Add current user to docker group for sudo-less docker access.
usermod -aG docker $username

# Crontab to update backdrops for TV screensaver on Samba share.
echo "0 */2 * * * /home/$username/.local/bin/update-backdrops.sh" | crontab -u $username -

if [[ $dotfiles_repo ]]; then
    # Load dotfiles.
    cd /home/$username
    git clone https://github.com/$dotfiles_repo dotfiles
    mv dotfiles/.git .git
    git config --global --add safe.directory /home/$username
    git reset --hard
    git remote rm origin
    git remote add origin git@github:$dotfiles_repo.git
    rm -R dotfiles
    echo "*" > .gitignore

    # Update work email for git configuration.
    sed -i "s/work@email.com/$git_work_email/" .gitconfig-work
    git update-index --assume-unchanged .gitconfig-work
    mv .git .dotfiles

    # Set crypt password for backup scripts.
    echo "export CRYPT_PASSWORD=$crypt_password" > /root/.secrets
    chmod 400 /root/.secrets

    # Skip, I'm using systemd-boot now
    # Apply GRUB configuration from dotfiles.
    #cp .etc/default/grub /etc/default/grub
    #grub-mkconfig -o /boot/grub/grub.cfg || true

    # Symlink machine-specific Sway config for my current device.
    ln -fs /home/$username/.config/sway/$hostname /home/$username/.config/sway/machine

    # Symlink machine-specific jellyfin-mpv-shim config.
    ln -fs /home/$username/.config/jellyfin-mpv-shim/conf.$hostname.json /home/$username/.config/jellyfin-mpv-shim/conf.json

    # Make sure everything is owned by the user.
    chown -R $username:$username .

    # Enable backups.
    echo "0 */4 * * * /home/$username/.local/bin/backup.sh" | crontab -
fi

# Configure firewall.
ufw allow 8096/tcp # Jellyfin passthrough to the server (socat).
ufw route allow from 192.168.137.10 # To allow traffic from asgard (pushing to github, Bazarr not breaking)

# Copy over /etc files.
rsync -av /home/$username/.etc/ /etc/

# Install angular globally
npm i -g @angular/cli
