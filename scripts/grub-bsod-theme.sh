#!/usr/bin/env bash
set -euo pipefail

# This script will install GRUB BSOD theme.
# To enable it, you need to manually edit your /etc/default/grub
# and set GRUB_THEME="/boot/grub/themes/bsol/theme.txt" there.

git clone https://github.com/ewancoder/bsol /tmp/bsol
cp -r /tmp/bsol/bsol /boot/grub/themes/
echo 'GRUB_THEME="/boot/grub/themes/bsol/theme.txt"' >> /etc/default/grub
