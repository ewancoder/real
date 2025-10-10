#!/usr/bin/env bash
set -euo pipefail

# Nvidia utils for Docker integration.

firstboot_packages+=(
    nvidia-container-toolkit # Needed to pass GPU to our Jellyfin container.
)
