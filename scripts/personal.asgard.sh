#!/usr/bin/env bash
set -euo pipefail

dotfiles_repo="ewancoder/dotfiles-asgard"

# Fix failing rutracker dns.
echo "104.21.32.39 rutracker.org" > /etc/hosts

# For server it's the same.
tyrUser=$username

# Pet Projects.
#mkdir -p /data
#mkdir -p /mnt/data/tyr/dev/infra/cache
#chown $tyrUser:$tyrUser /mnt/data/tyr
#chown $tyrUser:$tyrUser /mnt/data/tyr/dev
#chown $tyrUser:$tyrUser /mnt/data/tyr/dev/infra
#chown $tyrUser:$tyrUser /mnt/data/tyr/dev/infra/cache
#mkdir -p /mnt/data/tyr/infra/{pgadmin,redisinsight,seq}
#chown $tyrUser:$tyrUser /mnt/data/tyr/infra
#chown $tyrUser:$tyrUser /mnt/data/tyr/infra/redisinsight
#chown $tyrUser:$tyrUser /mnt/data/tyr/infra/seq
#chown 5050:5050 /mnt/data/tyr/infra/pgadmin

# Link for /data folders
mkdir -p /data
[ ! -e /data/tyr ] && ln -fs /mnt/data/tyr /data/tyr
[ ! -e /data/lab ] && ln -fs /mnt/data/lab /data/lab

#mkdir -p /mnt/data/lab/{backdrops,cache,configs}
# TODO: the following 2 statements (cold/hot) fail for some reason.
#[ ! -e /mnt/data/lab/cold ] && ln -fs /mnt/lab-cold /mnt/data/lab/cold
#[ ! -e /mnt/data/lab/hot ] && ln -fs /mnt/lab-hot /mnt/data/lab/hot
#[ ! -e /data/lab ] && ln -fs /mnt/data/lab /data/lab

# Local ssh/gnupg for reinstalling the OS.
#mkdir -p /mnt/data/security/{ssh,gnupg,sbctl}
#chown $username:$username /mnt/data/security/{ssh,gnupg}
[ ! -e /home/$username/.ssh ] && ln -fs /mnt/data/security/ssh /home/$username/.ssh
[ ! -e /home/$username/.gnupg ] && ln -fs /mnt/data/security/gnupg /home/$username/.gnupg

# Restore sbctl from backup
mv /var/lib/sbctl /var/lib/sbctl_backup || true
[ ! -e /var/lib/sbctl ] && ln -fs /mnt/data/security/sbctl /var/lib/sbctl

# Media Server
#mkdir -p /mnt/data/tyrm/configs
#chown $tyrUser:$tyrUser /mnt/data/tyrm
#chown $tyrUser:$tyrUser /mnt/data/tyrm/configs
#mkdir -p /mnt/data/tyrm/screensaver
#chown $tyrUser:$tyrUser /mnt/data/tyrm/screensaver
#[ ! -e /mnt/data/tyrm/data ] && ln -fs /mnt/media /mnt/data/tyrm/data

# Change default SSH port, disable Password auth and Root login.
sed -i "s/^#\?Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Add users to docker group for sudo-less docker access.
usermod -aG docker $tyrUser

# Crontab to update backdrops for TV screensaver on Samba share.
echo "0 */2 * * * /home/tyr/.ewancoder-dotfiles/.local/bin/backdrops.sh" | crontab -u $username -

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

# We have custom rules for systemd-networkd for ethernet/wifi specifics.
# Temporarily disabling this: using WiFi again.
#sed -i "s/EnableNetworkConfiguration=true/EnableNetworkConfiguration=false/g" /etc/iwd/main.conf

# Copy over /etc files.
rsync -av /home/$username/.etc/ /etc/

# Configure firewall.
ufw allow $ssh_port     # SSH.
ufw allow 139,445/tcp   # Samba.
ufw allow 2377/tcp      # Docker swarm.
ufw allow 7946/tcp      # Docker swarm.
ufw allow 7946/udp      # Docker swarm.
ufw allow 4789/udp      # Docker swarm.
ufw allow 8096/tcp      # Jellyfin.
ufw allow 7359/udp      # Jellyfin.
#ufw allow 33333        # Torrenting, using VPN for now.

# TODO: Might need to re-enroll TPM for disks.
# TODO: Join to Swarm cluster, start tyr-lab.
