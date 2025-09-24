#!/usr/bin/env bash
set -euo pipefail

mess -t "Setup root password and your user"
mess "Set up root password"
if [ -z $root_password ]; then
    passwd root
else
    echo $root_password | passwd root --stdin
fi

if [ ! "$(id $username)" ]; then
    mess "Create user"
    useradd -m $username
else
    mess "User $username already exists, skipping creating..."
fi
mess "Set up user password"
if [ -z $user_password ]; then
    passwd $username
else
    echo $user_password | passwd $username --stdin
fi

mess -t "Setup hostname & timezone"
mess "Set hostname - $hostname"
echo "$hostname" > /etc/hostname
mess "Set local timezone ($timezone)"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime

mess -t "Uncomment locales"
for i in "${locale[@]}"; do
    mess "Add locale $i"
    sed -i "s/^#$i/$i/g" /etc/locale.gen
done
mess "Generate locales"
locale-gen
mess "Set up default locale (${locale[0]})"
echo "LANG=${locale[0]}" > /etc/locale.conf
mess "Set up keymap"
echo "KEYMAP=$keymap" > /etc/vconsole.conf

mess -t "Prepare for software installation"
mess "Add multilib"
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
mess "Update packages including multilib"
pacman -Syy

mess "Remove CPU ucodes if exists, to prevent conflicts"
rm -f /boot/intel-ucode.img /boot/amd-ucode.img

mess -t "Install packages"
if [ ${#special_packages[@]} -gt 0 ] || [ ${#essential_packages[@]} -gt 0 ] || [ ${#user_packages[@]} -gt 0 ]; then
    pacman -S ${special_packages[@]} ${essential_packages[@]} ${user_packages[@]} --noconfirm
else
    mess "No packages to install, skipping..."
fi

mess -t "Install grub"
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot
if [[ ! -z $windows_efi_volume ]]; then
    mess "Mounting windows EFI volume for generating grub config"
    mkdir -p /mnt/temp
    mount $windows_efi_volume /mnt/temp
fi
mess "Generating grub config"
grub-mkconfig -o /boot/grub/grub.cfg
if [[ ! -z $windows_efi_volume ]]; then
    mess "Unmounting windows EFI volume"
    umount /mnt/temp
    rm -r /mnt/temp
fi

mess "Configure MAKEPKG to use all your cores, not just one"
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf

mess "Add user to sudoers file, and tweak pacman access for yay installation"
echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "$username ALL=(ALL:ALL) NOPASSWD: /usr/bin/pacman" >> /etc/sudoers

if which yay > /dev/null; then
    mess "Yay already installed, skipping installation"
else
    mess "Install yay"
    git clone --branch yay --single-branch https://github.com/archlinux/aur.git /tmp/aur
    chown -R $username /tmp/aur
    runuser -l $username -c 'cd /tmp/aur && makepkg'
    pacman -U --noconfirm /tmp/aur/*.pkg.tar.zst
fi

mess "Install yay user packages"
sudo -u $username yay -S --noconfirm ${yay_user_packages[@]}

mess "Make sure PC doesn't die when pressing power button once"
sed -i 's/^#HandlePowerKey=poweroff/HandlePowerKey=ignore/' /etc/systemd/logind.conf
sed -i 's/^#HandlePowerKeyLongPress=ignore/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf

mess "Changing default shell"
chsh -s $shell $username

mess "Turn on Swap on RAM"
echo "zram" > /etc/modules-load.d/zram.conf
echo "ACTION==\"add\", KERNEL==\"zram0\", ATTR{initstate}==\"0\", ATTR{comp_algorithm}=\"zstd\", ATTR{disksize}=\"${swapsize}G\", RUN=\"/usr/bin/mkswap -U clear %N\", TAG+=\"systemd\"" > /etc/udev/rules.d/99-zram.rules
echo '/dev/zram0 none swap defaults,discard,pri=100 0 0' >> /etc/fstab

mess "Removing unused / orphan packages, cleaning up"
pacman -Rns `pacman -Qdtq` --noconfirm || true

mess "Set up wifi"
mkdir -p /etc/iwd
echo -e "[General]\nEnableNetworkConfiguration=true\n[Network]\nNameResolvingService=systemd" > /etc/iwd/main.conf
systemctl enable iwd systemd-resolved
mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
echo -e "[Service]\nExecStart=\nExecStart=/usr/lib/systemd/systemd-networkd-wait-online --interface=$wlan_interface" > /etc/systemd/system/systemd-networkd-wait-online.service.d/override.con0

# Set up NTP.
sed -i 's/#NTP=/NTP=time.google.com/g' /etc/systemd/timesyncd.conf
timedatectl set-ntp true

sleep 10
mess "Synchronize hardware clock"
hwclock --systohc # Consider not doing that.

# Change default SSH port.
sed -i "s/^#\?Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config

if [ ${#service} -gt 0 ]; then
    mess -t "Enable services"
    for s in "${service[@]}"; do
        mess "Enable $s service"
        systemctl enable "$s"
    done
fi

if [ -f /custom.sh ]; then
    mess -t "Execute custom script"
    /custom.sh
fi
