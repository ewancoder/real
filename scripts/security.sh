#!/usr/bin/env bash
set -euo pipefail

# This scripts sets up default security rules (like firewall).
ufw default deny
#ufw enable # This needs to be done on first boot.
