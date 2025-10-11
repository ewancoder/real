#!/usr/bin/env bash
set -euo pipefail

# This is a custom script that runs at the end of system installation.
# Delete it if you do not need it.

# TODO: (need to do after install manually)
# 1. Login to Dropbox on first start.

dotfiles_repo="ewancoder/dotfiles"

# Fix failing rutracker dns
echo "104.21.32.39 rutracker.org" > /etc/hosts

# Restore symlinks to mnt
mkdir -p /mnt/data/home/{projects,work,.zen}
mkdir -p /mnt/data/Dropbox
mkdir -p /mnt/data/security/{ssh,gnupg}
mkdir -p /mnt/data/tyr
mkdir -p /data
chown $username:$username /mnt/data/home
chown $username:$username /mnt/data/home/{projects,work,.zen}
chown $username:$username /mnt/data/Dropbox
chown $username:$username /mnt/data/security/{ssh,gnupg}
chown 2000:2000 /mnt/data/tyr
ln -fs /mnt/data/home/projects /home/$username/projects
ln -fs /mnt/data/home/work /home/$username/work
ln -fs /mnt/data/home/.zen /home/$username/.zen
ln -fs /mnt/data/Dropbox /home/$username/Dropbox
ln -fs /mnt/data/security/ssh /home/$username/.ssh
ln -fs /mnt/data/security/gnupg /home/$username/.gnupg
ln -fs /mnt/data/tyr /data/tyr

# DEV env pet projects
# TODO: properly create `tyr` user, and /data/tyr folder, possibly use a separate script for this.
# Also need to join it to Swarm etc. Basically use TyR deployment scripts at this stage. And not at laptop probably.

if [[ $dotfiles_repo ]]; then
    cd /home/$username
    git clone https://github.com/$dotfiles_repo dotfiles
    mv dotfiles/.git .git
    git config --global --add safe.directory /home/$username
    git reset --hard
    git remote rm origin
    git remote add origin git@github:$dotfiles_repo.git
    rm -R dotfiles
    echo "*" > .gitignore
    sed -i "s/work@email.com/$git_work_email/" .gitconfig-work
    git update-index --assume-unchanged .gitconfig-work
    mv .git .dotfiles
    echo "export CRYPT_PASSWORD=$crypt_password" > /root/.secrets
    chmod 600 /root/.secrets
    git clone https://github.com/ewancoder/bsol /tmp/bsol
    cp .etc/default/grub /etc/default/grub
    cp -r /tmp/bsol/bsol /boot/grub/themes/
    grub-mkconfig -o /boot/grub/grub.cfg
    ln -s /home/$username/.config/sway/$hostname /home/$username/.config/sway/machine

    # Headless Dropbox install
    curl -L "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

    chown -R $username:$username .

    # Enable backups.
    echo "0 */4 * * * /home/$username/.local/bin/backup.sh" | crontab -
fi

# Install angular globally
npm i -g @angular/cli
