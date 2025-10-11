#!/usr/bin/env bash
set -euo pipefail

# This scripts sets up firmware for Asus Scar G17 laptop.
# Currently we need it to make the sound work as expected, and not just subwoofer.

echo "options snd-hda-intel patch=hda-jack-retask.fw,hda-jack-retask.fw,hda-jack-retask.fw,hda-jack-retask.fw" > /etc/modprobe.d/hda-jack-retask.conf
echo -e "[codec]\n0x10ec0285 0x104312bf 0\n\n[pincfg]\n0x12 0x90a60140\n0x13 0x40000000\n0x14 0x90170150\n0x16 0x40f000f0\n0x17 0x90170151\n0x18 0x40f000f0\n0x19 0x411111f0\n0x1a 0x411111f0\n0x1b 0x40f000f0\n0x1d 0x40663a45\n0x1e 0x40f000f0\n0x21 0x40f000f0" > /lib/firmware/hda-jack-retask.fw
