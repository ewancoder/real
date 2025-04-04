#!/usr/bin/env bash
set -euo pipefail

# Change the following configuration variables:
root_password=""
user_password=""
rdp_username=""
rdp_password=""
hostname="ivanpc"
windows_efi_volume=""
locale="Asia/Tbilisi"
keymap="dvorak"
user_name="ewancoder"
dotfiles_repo="ewancoder/dotfiles"
git_user_name="Ivan Zyranau"
git_email="ewancoder@gmail.com"
git_work_email="work@email.com"

# Also change 2 special packages below:
# - intel-ucode for intel, amd-ucode for amd
# - nvidia-open for nvidia, google what to install for AMD, remove for integrated graphics
# !!! Important to install NVIDIA drivers AFTER reboot into the actual system. Do NOT install them here.
# - Same for Steam cause it requires GPU drivers.

# Packages that are essential for the system to work (WM-agnostic): drivers, utils, etc.
special_packages=(
    intel-ucode # Intel CPU security patches, for AMD use amd-ucode.
    #nvidia-open # Nvidia open-source latest proprietary drivers.

    # GRUB bootloader:
    # - efibootmgr is needed to see EFI volumes.
    # - os-prober is needed to generate entry for Windows (if it's installed).
    grub efibootmgr os-prober

    sudo    # SUDO to be able to run sudo by a user.
    iwd     # Network daemon to be able to connect to Wi-Fi.

    # Needed to be able to build YAY (can be uninstalled later I guess?).
    base-devel git go

    # Sound system.
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack

    # Bluetooth support.
    bluez bluez-utils

    # Docker. Script enables it later so we need it here not to break it.
    # If you do not need docker - remove it from here and from below.
    # buildx is needed for Rider docker debug
    docker docker-compose docker-buildx

    playerctl   # In order to be able to control players with multimedia keys, systemwide.

    unzip       # Archives management. For now I only needed to unzip. Will add others here later.

    btrfs-progs # Utility to manage BTRFS filesystem. Might be handy to manipulate drives live.
)

# Essential packages for a working WM environment.
essential_packages=(
    wlroots                 # Wayland composer, dependency for many WMs.
    xdg-desktop-portal-wlr  # Abitily to share screens with wlroots compositor, uses slurp to select a screen.
    gnome-keyring           # Ability to save passwords for GTK apps (like Skype).
    swaybg  # Background for Sway.
    fuzzel  # Application launcher.

    # Screenshotting tools.
    # - slurp is used to select part of the screen and output to stdout (and to select a monitor to screen share).
    # - grim is used to screenshot the selected part (or whole monitor) and output to file (or pipe).
    # - wl-clipboard is used to manage clipboard in Wayland (and pipe grim output to it).
    # - swappy is used to edit screenshots inline
    slurp grim wl-clipboard swappy

    # Fonts (TODO: figure out which ones I need).
    # - otf-font-awesome is needed for swappy
    noto-fonts ttf-liberation otf-font-awesome

    pavucontrol # GUI audio manager.
    sway        # Main WM.
    foot        # Terminal for Wayland.
    libnotify   # Notification subsystem (use notify-send).
    mako        # Notification daemon (shows notifications in Wayland).

    qt5-wayland qt6-wayland # Wayland support for QT apps.
    xorg-xwayland           # Support for X apps under Wayland.
    cronie rsync            # For backups.
)

# Additional user software.
user_packages=(
    gvim            # Text editor. GVIM package contains VIM with +clipboard support.
    less            # Tool for limiting terminal output.
    htop            # Tool for pretty resources analysis.
    qbittorrent     # Torrent client.
    #steam           # Steam gaming client.
    code            # VS Code.
    discord         # Official Discord client.
    firefox         # Firefox browser (consider removing, using Chrome).
    encfs           # Encryption filesystem client for protecting folders.

    # KDE PDF reader with many features (consider changing to vi-like one, KDE brings a lot of dependencies).
    # qt6-multimedia-ffmpeg or qt6-multimedia-gstreamer is a dependency of okular, preselect ffmpeg.
    okular qt6-multimedia-ffmpeg

    freerdp             # RDP client to connect to my Windows laptop.
    ncspot              # Console Spotify client.
    npm                 # NodeJS & NPM.
    libreoffice-fresh   # Office packages.
    ranger              # VI-like file manager.
    mpv                 # Video player.
    imv                 # Image viewer.
    zsh                 # Alternative shell.
    openssh             # Used to connect to SSH servers & generate ssh-keygen.
    telegram-desktop    # Telegram messenger.
    thefuck             # Automatic wrong command fixing.
    tmux                # Terminal multiplexer.
    xournalpp           # Handwritten brainstorming journal. (TODO: alternatively try Lorien: aur lorien-bin package)
    ncdu                # NCurses version of du, to see how much space is taken.
    net-tools           # For ifconfig for script that shows status of downloads/uploads.
    jellyfin-mpv-shim   # For integrating mpv with jellyfin.

    # Git for development: duplicated here in case we decide we don't need YAY.
    # github-cli is needed for auth credential manager to be able to authenticate (without ssh).
    git github-cli

    # Android phone mounting.
    android-file-transfer   # Usage: aft-mtp-mount ~/mnt

    # .NET development.
    dotnet-sdk-8.0 dotnet-sdk aspnet-runtime-8.0 aspnet-runtime
)
yay_user_packages=(
    google-chrome       # Main browser.
    dropbox             # Cloud storage.
    zoom                # Messaging for work.
    uhk-agent-appimage  # UHK agent.
    skypeforlinux-bin   # Skype.
    teams-for-linux-bin # Teams (instead of Skype).
    slack-desktop       # Slack.
    sptlrx-bin          # Real-time lyrics for Spotify.
    anki                # Anki cards app.
    zen-browser-bin     # Trying the new zen browser.
    rider               # .NET development.
)

# TODO: Run the following inside chroot
ln -sf /usr/share/zoneinfo/$locale /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=$keymap" > /etc/vconsole.conf
echo "$hostname" > /etc/hostname
echo $root_password | passwd root --stdin
useradd -m $user_name
echo $user_password | passwd $user_name --stdin
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syy

# Remove this files if it exists (otherwise re-installation fails)
rm -f /boot/intel-ucode.img

pacman -S ${special_packages[@]} ${essential_packages[@]} ${user_packages[@]} --noconfirm

# Fix failing rutracker dns
echo "104.21.32.39 rutracker.org" > /etc/hosts

# Restore symlinks to mnt
ln -fs /mnt/data/home/ssh /home/$user_name/.ssh
ln -fs /mnt/data/home/projects /home/$user_name/projects
ln -fs /mnt/data/home/work /home/$user_name/work
ln -fs /mnt/data/Dropbox /home/Dropbox

# Enable backups.
systemctl enable cronie
echo "0 */4 * * * /home/ewancoder/.local/bin/backup.sh" | crontab -

systemctl enable docker
systemctl enable bluetooth
echo "$user_name ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "$user_name ALL=(ALL:ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot
if [[ ! -z $windows_efi_volume ]]; then
    mkdir -p /mnt/temp
    mount $windows_efi_volume /mnt/temp
fi
grub-mkconfig -o /boot/grub/grub.cfg
if [[ ! -z $windows_efi_volume ]]; then
    umount /mnt/temp
    rm -r /mnt/temp
fi
# Wifi setup
mkdir -p /etc/iwd
echo """[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=systemd""" > /etc/iwd/main.conf
systemctl enable iwd systemd-resolved
# Configure RDP ethernet to laptop
echo """[Match]
Name=eno2

[Network]
Address=192.168.2.3/24
Domains=~local""" > /etc/systemd/network/20-wired.network
systemctl enable systemd-networkd
# configure makepkg to use more than 1 cpu core
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf
# yay
git clone --branch yay --single-branch https://github.com/archlinux/aur.git
chown -R $user_name aur
runuser -l $user_name -c 'cd /aur && makepkg'
cd aur
pacman -U --noconfirm *.pkg.tar.zst
cd ..
rm -r aur
sudo -u $user_name yay -S --noconfirm ${yay_user_packages[@]}
if [[ $dotfiles_repo ]]; then
    cd /home/$user_name
    git clone https://github.com/$dotfiles_repo dotfiles
    mv dotfiles/.git .git
    git config --global --add safe.directory /home/$user_name
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

    chown -R $user_name:$user_name .
fi

# TODO: figure out how to do that for the user and automatically
chsh -s /bin/zsh $user_name

# TODO: Test everything below
sed -i 's/^#HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandlePowerKeyLongPress=ignore/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf

mkdir -p /etc/systemd/system/getty@tty1.service.d
echo """[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $user_name %I \$TERM
""" > /etc/systemd/system/getty@tty1.service.d/autologin.conf

echo "zram" > /etc/modules-load.d/zram.conf
echo 'ACTION=="add", KERNEL=="zram0", ATTR{initstate}=="0", ATTR{comp_algorithm}="zstd", ATTR{disksize}="20G", RUN="/usr/bin/mkswap -U clear %N", TAG+="systemd"' > /etc/udev/rules.d/99-zram.rules
echo '/dev/zram0 none swap defaults,discard,pri=100 0 0' >> /etc/fstab

# Install angular globally
npm i -g @angular/cli

pacman -R --noconfirm go
pacman -Qdtq | pacman -Rns -
read -p "Make sure to remove duplicate zram from fstab if needed. Installation is DONE! Congrats!"

exit
umount -R /mnt
reboot
