#!/usr/bin/env bash
set -euo pipefail

# AMD GPU (open-source amdgpu kernel driver + Mesa userspace stack).
# Kernel driver and firmware are provided by linux + linux-firmware (pacstrap).

packages+=(
    mesa                # OpenGL/Vulkan drivers for AMD.
    vulkan-radeon       # Vulkan driver for AMD GPUs.
    lib32-mesa          # 32-bit OpenGL, needed for Steam & 32-bit apps.
    lib32-vulkan-radeon # 32-bit Vulkan, needed for Steam & 32-bit apps.
)
