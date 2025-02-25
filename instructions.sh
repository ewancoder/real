# Connect to internet, mount all needed volumes to /mnt, then run these
# For PC - separate volume for /mnt/data
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# run install.sh under chroot

fdisk -> t -> uefi

# To reinstall with btrfs:
btrfs filesystem show
btrfs device add /dev/xxx /
btrfs device remove /dev/xxx / # removes device from FS
btrfs balance start /





# [alternative install from another repo - streamlined]
git clone --depth=1 https://github.com/wick3dr0se/archstrap
cd archstrap
sudo archstrap /mnt/archstrap

# Installation from another repo:
# - install squashfs-tools btrfs-progs
# - reformat some disks
# - download https://www.mirrorservice.org/sites/ftp.archlinux.org/iso/2025.02.01/arch/x86_64/airootfs.sfs
# - unsquash it
unsquashfs airootfs.sfs

mount --bind squashfs-root squashfs-root
mount -t proc none squashfs-root/proc
mount -t sysfs none squashfs-root/sys
mount -o bind /dev squashfs-root/dev
mount -o bind /dev/pts squashfs-root/dev/pts  ## important for pacman (for signature check)

# This doesn't always works, with systemd-resolved I guess it doesn't.
cp -L /etc/resolv.conf squashfs-root/etc  ## this is needed to use networking within the chroot
# So, alternatively:
mount --rbind /run squashfs-root/run

# Also needed to run this:
pacman-key --init
pacman-key --populate archlinux

chroot squashfs-root bash





# For virtualbox:
fdisk /dev/sda
n, +1G
t, uefi
n, max
w

mkfs.fat -F 32 /dev/sda1
mkfs.btrfs /dev/sda2

mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot




#new (but probably i can mount it without this? need to check)
#android-file-transfer
#then: aft-mtp-mount ~/mnt

# ALSO
# sudo npm i -g @angular/cli

# Then in project
# npm i && ng serve

# My FS info:

# /
/dev/nvme1n1p4 + 5

# /boot
/dev/nvme1n1p3

# /mnt/backup
/dev/nvme2n1p5

# /mnt/data
/dev/nvme1n1p6 + 7 + 8

# (windows EFI)
/dev/nvme2n1p1

# (TESTING SCRIPT PARTITION - reinstalling system without the grub)
/dev/nvme1n1p9 (40 GB)
