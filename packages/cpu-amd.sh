#!/usr/bin/env bash
set -euo pipefail

# Firmware / hardware packages for AMD CPU.

packages+=(
    amd-ucode # AMD CPU security patches.
)
