#!/usr/bin/env bash
set -euo pipefail

# Firmware / hardware packages for Intel CPU.

packages+=(
    intel-ucode # Intel CPU security patches.
)
