#!/usr/bin/env bash
set -euo pipefail

dotfiles_repo="ewancoder/dotfiles-asgard"

# Fix failing rutracker dns.
echo "104.21.32.39 rutracker.org" > /etc/hosts

# For server it's the same.
tyrUser=$username

# Pet Projects.
mkdir -p /data
mkdir -p /mnt/data/tyr/dev/infra/cache
chown $tyrUser:$tyrUser /mnt/data/tyr
chown $tyrUser:$tyrUser /mnt/data/tyr/dev
chown $tyrUser:$tyrUser /mnt/data/tyr/dev/infra
chown $tyrUser:$tyrUser /mnt/data/tyr/dev/infra/cache
mkdir -p /mnt/data/tyr/infra/{pgadmin,redisinsight,seq}
chown $tyrUser:$tyrUser /mnt/data/tyr/infra
chown $tyrUser:$tyrUser /mnt/data/tyr/infra/redisinsight
chown $tyrUser:$tyrUser /mnt/data/tyr/infra/seq
chown 5050:5050 /mnt/data/tyr/infra/pgadmin
[ ! -e /data/tyr ] && ln -fs /mnt/data/tyr /data/tyr

mkdir -p /mnt/data/lab/{backdrops,cache,configs}
# TODO: the following 2 statements (cold/hot) fail for some reason.
[ ! -e /mnt/data/lab/cold ] && ln -fs /mnt/lab-cold /mnt/data/lab/cold
[ ! -e /mnt/data/lab/hot ] && ln -fs /mnt/lab-hot /mnt/data/lab/hot
[ ! -e /data/lab ] && ln -fs /mnt/data/lab /data/lab

# Local ssh/gnupg for reinstalling the OS.
mkdir -p /mnt/data/security/{ssh,gnupg,sbctl}
chown $username:$username /mnt/data/security/{ssh,gnupg}
[ ! -e /home/$username/.ssh ] && ln -fs /mnt/data/security/ssh /home/$username/.ssh
[ ! -e /home/$username/.gnupg ] && ln -fs /mnt/data/security/gnupg /home/$username/.gnupg

# Media Server
mkdir -p /mnt/data/tyrm/configs
chown $tyrUser:$tyrUser /mnt/data/tyrm
chown $tyrUser:$tyrUser /mnt/data/tyrm/configs
mkdir -p /mnt/data/tyrm/screensaver
chown $tyrUser:$tyrUser /mnt/data/tyrm/screensaver
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
echo "0 */2 * * * /home/tyr/.ewancoder-dotfiles/.local/bin/backdrops.sh" | crontab -u $username -

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
    git --git-dir=/home/$username/.dotfiles/ --work-tree=/home/$username -c url."https://github.com/".insteadOf="git@github:" submodule update --init --recursive

    # Make sure everything is owned by the user.
    chown -R $username:$username .

    # Enable backups.
    echo "0 */4 * * * /home/$username/.local/bin/backup.sh" | crontab -
fi

# Set crypt password for backup scripts.
echo "export CRYPT_PASSWORD=$crypt_password" > /root/.secrets
chmod 400 /root/.secrets

# We have custom rules for systemd-networkd for ethernet/wifi specifics.
sed -i "s/EnableNetworkConfiguration=true/EnableNetworkConfiguration=false/g" /etc/iwd/main.conf

# Copy over /etc files.
rsync -av /home/$username/.etc/ /etc/

# Configure firewall.
ufw allow $ssh_port     # SSH.
ufw allow 139,445/tcp   # Samba.
ufw allow 2377/tcp      # Docker swarm.
ufw allow 7946/tcp      # Docker swarm.
ufw allow 7946/udp      # Docker swarm.
ufw allow 4789/udp      # Docker swarm.
ufw allow 33333         # Torrenting.

# Consider doing this in firstboot script:
# Might be needed for AdGuard to work on host system.
#ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
#systemctl reload-or-restart systemd-resolved

# TODO: Might need to re-enroll TPM for disks.
