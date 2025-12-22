#!/usr/bin/env bash
set -euo pipefail

# Packages for working with FIDO2 tokens (security keys like yubikey) for TPM enrollment.

packages+=(
    libfido2 # FIDO keys support for TPM enrollment as FIDO2 token.
)
