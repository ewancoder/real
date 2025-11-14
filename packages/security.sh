#!/usr/bin/env bash
set -euo pipefail

packages+=(
    # Firewall.
    ufw
)

services+=(
    ufw
)
