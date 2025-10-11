#!/usr/bin/env bash
set -euo pipefail

# Nvidia utils for Docker integration.

packages+=(
    nvidia-container-toolkit # Needed to pass GPU to our Jellyfin container.
)
