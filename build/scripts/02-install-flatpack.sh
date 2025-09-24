#!/usr/bin/env bash
set -eux -o pipefail

flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo