#!/usr/bin/env bash
set -euo pipefail

# Setting up root password based on value from config.
mess -t "Setup root password and your user"
mess "Set up root password"
if [ -z $root_password ]; then
    passwd root
else
    echo $root_password | passwd root --stdin
fi

# Creating a new user. -m option automatically creates their /home/$username directory.
if [ ! "$(id $username)" ]; then
    mess "Create user"
    useradd -m $username
else
    mess "User $username already exists, skipping creating..."
fi

# Setting up user password based on value from config.
mess "Set up user password"
if [ -z $user_password ]; then
    passwd $username
else
    echo $user_password | passwd $username --stdin
fi

# Set up hostname of your machine. This is a unique network name of the machine.
mess -t "Setup hostname & timezone"
mess "Set hostname - $hostname"
echo "$hostname" > /etc/hostname

# Set up local timezone for your machine. Clock & other geo-services will use it to properly show time.
mess "Set local timezone ($timezone)"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime

# Generate locales that the system should support.
# For example, having both en-US and ru-RU locales will allow you switching the whole system from English to Russian and vise-versa.
mess -t "Uncomment locales"
for i in "${locale[@]}"; do
    mess "Add locale $i"
    sed -i "s/^#$i/$i/g" /etc/locale.gen
done
mess "Generate locales"
locale-gen

# Set up the first specified locale as the current/default one.
# The system will be displayed in a chosen language.
mess "Set up default locale (${locale[0]})"
echo "LANG=${locale[0]}" > /etc/locale.conf

# Set current/default keymap.
# For example, 'us' would mean TTY works on QWERTY, where 'dvorak' would mean TTY works on DVORAK.
# This only affects TTY/console, not the graphics environment.
mess "Set up keymap"
echo "KEYMAP=$keymap" > /etc/vconsole.conf

# Add multilib (32-bit) packages to the sources list, so we can install things like Steam.
# Default repo has only 64-bit packages.
mess -t "Prepare for software installation"
mess "Add multilib"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
mess "Update packages including multilib"
pacman -Syy

# When we are installing either Intel or AMD cpu microcodes - installation will fail if they already exist.
# So we are removing them here if they exist.
mess "Remove CPU ucodes if exists, to prevent conflicts"
rm -f /boot/intel-ucode.img /boot/amd-ucode.img

# Install all the packages from $special_packages, $essential_packages, and $user_packages from config.
mess -t "Install packages"
if [ ${#packages[@]} -gt 0 ]; then
    pacman -S ${packages[@]} --noconfirm
else
    mess "No packages to install, skipping..."
fi

# Install GRUB bootloader so we can select an OS during boot.
mess -t "Install grub"
# Enable OS prober - tool that scans partitions for other OS (like Windows) to include it in the GRUB boot menu.
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
# Install GRUB into your EFI directory (which should be mounted to /boot).
grub-install --target=x86_64-efi --efi-directory=/boot
if [[ ! -z $windows_efi_volume ]]; then
    # If Windows is running off a separate EFI volume, and we specify it in the config - mount it temporary for os-prober to find it.
    mess "Mounting windows EFI volume for generating grub config"
    mkdir -p /mnt/temp
    mount $windows_efi_volume /mnt/temp
fi
# Generate GRUB config: find any OS on your drives and generate the menu.
mess "Generating grub config"
grub-mkconfig -o /boot/grub/grub.cfg
if [[ ! -z $windows_efi_volume ]]; then
    # Unmount temporary Windows EFI if we mounted it.
    mess "Unmounting windows EFI volume"
    umount /mnt/temp
    rm -r /mnt/temp
fi

# During AUR installation, or any other manual package installation - makepkg tool compiles source code for you.
# By default it uses only 1 CPU core which is slow and inefficient.
# Here we are making sure it uses ALL available cores.
mess "Configure MAKEPKG to use all your cores, not just one"
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf

# Add your user to sudoers so it can run sudo.
mess "Add user to sudoers file, and tweak pacman access for yay installation"
echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
# Add pacman to exceptions so we can run it without password.
# TODO: this is obsolete and insecure so better remove this, I am using 'run0' now anyway.
#echo "$username ALL=(ALL:ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers

if which yay > /dev/null; then
    mess "Yay already installed, skipping installation"
else
    # Install YAY - helper to install AUR packages automatically.
    remove_go=0
    which go || remove_go=1
    pacman -S go # Needed to get & compile yay.
    mess "Install yay"
    git clone --branch yay --single-branch https://github.com/archlinux/aur.git /tmp/aur
    chown -R $username /tmp/aur
    runuser -l $username -c 'cd /tmp/aur && makepkg'
    pacman -U --noconfirm /tmp/aur/*.pkg.tar.zst
    if [ $remove_go -eq 1 ]; then
        # Delete go if installed just for building yay, and not from user packages.
        pacman -R --noconfirm go
    fi
fi

if [ $aur_install -eq 1 ] && [ "${#aur[@]}" -gt 0 ]; then
    # If we have any AUR packages in the config - install them using YAY...
    mess "Install AUR user packages"
    if [ $yay_ask -eq 1 ]; then
        # ...with confirmation required if $yay_ask is 1.
        sudo -u $username yay -S ${aur[@]}
    else
        # ...or without confirmation, completely automatic.
        sudo -u $username yay -S --noconfirm ${aur[@]}
    fi
else
    mess -w "Skipping installing AUR packages. Make sure you install them manually after system install."
fi

if [ "${#flatpak[@]}" -gt 0 ]; then
    # If flatpak packages exist in config - install them.
    # This will only work if flatpak itself was installed in the system.
    # (one of the packages in config should be flatpak)
    mess "Install Flatpak packages"
    sudo flatpak install ${flatpak[@]} --noninteractive --system
fi

# Configure power button to not do anything (ignore).
# Only listen to it on a long press.
# Also disable sleep for laptops (lid and button events) cause most likely sleep doesn't work correctly.
mess "Make sure PC doesn't die when pressing power button once"
sed -i 's/^#HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandlePowerKeyLongPress=ignore/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf
sed -i 's/^#HandleRebootKey=reboot/HandleRebootKey=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleRebootKeyLongPress=poweroff/HandleRebootKeyLongPress=reboot/' /etc/systemd/logind.conf
sed -i 's/^#HandleSuspendKey=suspend/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandleLidSwitchExternalPower=suspend/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf

# Set current/default shell from config.
mess "Changing default shell"
chsh -s $shell $username

# TODO: Implement a choice: no swap, swap on RAM, or swap on FILE/partition.
# Create swap:
# 1. If $swap_partition=/dev/sda5, then we'll use /dev/sda5 partition as swap.
#    This partition should be manually formatted (mkswap) before install script starts.
# 2. If $swap_file and $swap_file_size are specified, we are creating a new swap file in the filesystem.
#    For example, $swap_file=/swap, $swap_file_size=20, means create /swap file with the size of 20G.
# 3. If both these variables are empty - we use ZRAM swap on RAM.
if [[ -n "$swap_partition" ]]; then
    mess "Configuring swap on partition: $swap_partition"
    echo "$swap_partition none swap defaults 0 0" >> /etc/fstab
elif [[ -n "$swap_file" ]]; then
    mess "Configuring swap on file: $swap_file"
    if [[ ! -f "$swap_file" ]]; then
        fallocate -l "${swap_file_size}G" "$swap_file"
        chmod 600 "$swap_file"
        mkswap "$swap_file"
    fi
    echo "$swap_file none swap defaults 0 0" >> /etc/fstab
else
    mess "Configuring swap on RAM (zram)"
    echo "zram" > /etc/modules-load.d/zram.conf
    echo "ACTION==\"add\", KERNEL==\"zram0\", ATTR{initstate}==\"0\", ATTR{comp_algorithm}=\"zstd\", ATTR{disksize}=\"${swapsize}G\", RUN=\"/usr/bin/mkswap -U clear %N\", TAG+=\"systemd\"" > /etc/udev/rules.d/99-zram.rules
    echo '/dev/zram0 none swap defaults,discard,pri=100 0 0' >> /etc/fstab
fi

mess "Removing unused / orphan packages, cleaning up"
pacman -Rns `pacman -Qdtq` --noconfirm || true

# TODO: Implement an option of ethernet, or both.
#   IF using Ethernet - make sure to also tweak wait-online.target below.
# We are using bare-bones iwd/iwctl for connecting to wifi,
# and systemd-resolved for resolving DNS.
mess "Set up wifi"
# Add configuration for iwd:
# EnableNetworkConfiguration - use iwd for dhcp/dns, instead of relying on NetworkManager (we have it disabled).
# NameResolvingService - use systemd-resolved backend for resolving systemd.
mkdir -p /etc/iwd
echo -e "[General]\nEnableNetworkConfiguration=true\n[Network]\nNameResolvingService=systemd" > /etc/iwd/main.conf
# Enable iwd & systemd-resolved services.
systemctl enable iwd systemd-resolved
# Add a configuration for systemd-networkd wait-online target to only wait for wifi.
# By default it waits for all interfaces so wait-online target will never resolve.
# It will lead to Docker not being able to start on system start for whole 5 minutes until it times out,
# because Docker relies on wait-online.target.
# TODO: this needs to be tweaked for Eithernet if we are using Ethernet.
mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
echo -e "[Service]\nExecStart=\nExecStart=/usr/lib/systemd/systemd-networkd-wait-online --interface=$wlan_interface" > /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf

# Set up NTP.
# This is time synchronization service. We use hardcoded google server.
sed -i 's/#NTP=/NTP=time.google.com/g' /etc/systemd/timesyncd.conf
timedatectl set-ntp true

# Wait for time to be synchronized, and synchronize hardware clock.
# This synchronizes your OS time INTO your Motherboard time chip.
# TODO: consider not doing that, or doing that only if configured.
sleep 10
mess "Synchronize hardware clock"
hwclock --systohc

# Change default SSH port, disable Password auth and Root login.
sed -i "s/^#\?Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" /etc/ssh/sshd_config

# Add current user to docker group for sudo-less docker access.
usermod -aG docker $username

# Enable all the systemd services that are specified in the config.
if [ ${#services} -gt 0 ]; then
    mess -t "Enable services"
    for s in "${services[@]}"; do
        mess "Enable $s service"
        systemctl enable "$s"
    done
fi

# Execute your custom script if any.
if [ -f /custom.sh ]; then
    mess -t "Execute custom script"
    /custom.sh
fi

# Setup autologin for root for the firstboot script to be executed automatically after reboot.
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo """[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin root %I \$TERM
""" > /etc/systemd/system/getty@tty1.service.d/autologin.conf

echo '/firstboot.sh' > /root/.bash_profile
