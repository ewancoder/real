#!/usr/bin/env bash
set -euo pipefail

# This is a custom script that runs at the end of system installation.
# Delete it if you do not need it.

# (note to self) Update these 3 before install.
rdp_username=""
rdp_password=""
git_work_email="work@email.com"

dotfiles_repo="ewancoder/dotfiles"
git_user_name="Ivan Zyranau"
git_email="ewancoder@gmail.com"

# Fix failing rutracker dns
echo "104.21.32.39 rutracker.org" > /etc/hosts

# Restore symlinks to mnt
ln -fs /mnt/data/home/ssh /home/$username/.ssh
ln -fs /mnt/data/home/projects /home/$username/projects
ln -fs /mnt/data/home/work /home/$username/work
ln -fs /mnt/data/home.zen /home/$username/.zen
ln -fs /mnt/data/Dropbox /home/$username/Dropbox

# DEV env pet projects
ln -fs /mnt/data/pet/dp.pfx /root/dp.pfx
mkdir -p /data
ln -fs /mnt/data/pet/* /data/

# Enable backups.
echo "0 */4 * * * /home/ewancoder/.local/bin/backup.sh" | crontab -

if [[ $dotfiles_repo ]]; then
    cd /home/$username
    git clone https://github.com/$dotfiles_repo dotfiles
    mv dotfiles/.git .git
    git config --global --add safe.directory /home/$username
    git reset --hard
    rm -R dotfiles
    echo "*" > .gitignore
    sed -i "s/work@email.com/$git_work_email/" .gitconfig-work
    git update-index --assume-unchanged .gitconfig-work
    mv .git .dotfiles
    echo "export RDP_USERNAME=$rdp_username" >> .secrets
    echo "export RDP_PASSWORD=$rdp_password" >> .secrets

    # Additional post-processing.
    # For now always add it, I'm installing nvidia drivers later.
    #if [[ ! "${special_packages[@]}" =~ "nvidia" ]]; then
    #    echo "Removing --unsupported-gpu from Sway startup, because we are not using Nvidia."
    #    sed -i "s/--unsupported-gpu//" .zprofile
    #fi
    sed -i "s/Ivan Zyranau/$git_user_name/" .gitconfig
    sed -i "s/ewancoder@gmail.com/$git_email/" .gitconfig

    chown -R $username:$username .
fi

# Install angular globally
npm i -g @angular/cli
