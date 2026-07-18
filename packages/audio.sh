#!/usr/bin/env bash
set -euo pipefail

packages+=(
    # Sound system.
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack
    playerctl   # In order to be able to control players with multimedia keys, systemwide.
)
