#!/usr/bin/env bash
set -euo pipefail

# Nvidia driver.

firstboot_packages+=(
    nvidia-open         # Main NVIDIA open driver.
    lib32-nvidia-utils  # Needed for steam & 32-bit apps.
)
