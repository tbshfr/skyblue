#!/usr/bin/env bash
set -eux -o pipefail

PACKAGES_TO_INSTALL=(
    "chromium"
    "code"
)

if ! dnf5 install -y "${PACKAGES_TO_INSTALL[@]}"; then
    echo "Package installation failed"
    exit 1
fi