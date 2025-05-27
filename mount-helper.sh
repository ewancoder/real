#!/usr/bin/env bash
set -euo pipefail

# This is just a helper script that I run manually (it's not executed by the install script) in order to mount all my volumes when I reinstall the system.

root_boot_data_drive=/dev/nvme1n1
backup_volume=/dev/nvme2n1p3
hdd_volume=/dev/sda1
root_volume=${root_boot_data_drive}p4
boot_volume=${root_boot_data_drive}p3
data_volume=${root_boot_data_drive}p6

mkdir -p /mnt
mount $root_volume /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/mnt/data
mkdir -p /mnt/mnt/backup
mkdir -p /mnt/mnt/hdd

mount $boot_volume /mnt/boot
mount $data_volume /mnt/mnt/data
mount $backup_volume /mnt/mnt/backup
mount $hdd_volume /mnt/mnt/hdd

