#!/usr/bin/env bash
set -euo pipefail

# This is my (ewancoder) custom script that runs at the end of system installation.
# TODO: do not create symlinks within symlinks (like Dropbox/Dropbox, or projects/projects)

dotfiles_repo="ewancoder/dotfiles-asgard"

# Fix failing rutracker dns.
echo "104.21.32.39 rutracker.org" > /etc/hosts

# For server it's the same.
tyrUser=$username

# Pet Projects.
mkdir -p /data
mkdir -p /mnt/data/tyr
chown $tyrUser:$tyrUser /mnt/data/tyr
[ ! -e /data/tyr ] && ln -fs /mnt/data/tyr /data/tyr

# Local ssh/gnupg for reinstalling the OS.
mkdir -p /mnt/data/security/{ssh,gnupg,sbctl}
chown $username:$username /mnt/data/security/{ssh,gnupg}
[ ! -e /home/$username/.ssh ] && ln -fs /mnt/data/security/ssh /home/$username/.ssh
[ ! -e /home/$username/.gnupg ] && ln -fs /mnt/data/security/gnupg /home/$username/.ssh

# Media Server
mkdir -p /mnt/data/tyrm/configs
chown $tyrUser:$tyrUser /mnt/data/tyrm/configs
[ ! -e /mnt/data/tyrm/data ] && ln -fs /mnt/media /mnt/data/tyrm/data

mv /var/lib/sbctl /var/lib/sbctl_backup || true
[ ! -e /var/lib/sbctl ] && ln -fs /mnt/data/security/sbctl /var/lib/sbctl

# Change default SSH port, disable Password auth and Root login.
sed -i "s/^#\?Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Add users to docker group for sudo-less docker access.
usermod -aG docker $username
usermod -aG docker $tyrUser

# Crontab to update backdrops for TV screensaver on Samba share.
echo "0 */2 * * * /home/$username/.local/bin/update-backdrops.sh" | crontab -u $username -

# DEV env pet projects.
# TODO: properly create `tyr` user, and /data/tyr folder, possibly use a separate script for this.
# Also need to join it to Swarm etc. Basically use TyR deployment scripts at this stage. And not at laptop probably.

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
    mv .git .dotfiles

    # Make sure everything is owned by the user.
    chown -R $username:$username .

    # Enable backups.
    echo "0 */4 * * * /home/$username/.local/bin/backup.sh" | crontab -
fi
