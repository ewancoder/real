# Helpful reminders on what to mount where

## Asgard

- / (mapper/root) - btrfs
- /efi (mount -o umask=0077,uid=0,gid=0) - vfat 32
- /mnt/data (mapper/data) - btrfs
- /mnt/lab-hot - ext4 defaults,discard 0 2
- /mnt/lab-cold - btrfs defaults,noatime,space_cache=v2 0 0
