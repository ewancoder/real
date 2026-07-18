#!/usr/bin/env bash
set -euo pipefail

packages+=(
    unzip   # Archives management. For now I only needed to unzip. Will add others here later.
    btrfs-progs # Utility to manage BTRFS filesystem. Might be handy to manipulate drives live.
    ntfs-3g     # NTFS driver.
)
