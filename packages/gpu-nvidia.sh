#!/usr/bin/env bash
set -euo pipefail

# Nvidia driver.

packages+=(
    nvidia-open         # Main NVIDIA open driver.
    nvidia-utils        # Dependency of vulkan.
    lib32-nvidia-utils  # Needed for steam & 32-bit apps, dependency of lib32-vulkan.
)
