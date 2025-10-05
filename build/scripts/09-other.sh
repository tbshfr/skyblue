#!/usr/bin/env bash
set -eux -o pipefail

sed -i "s,^PRETTY_NAME=.*,PRETTY_NAME=\"skyblue-$(rpm -E %fedora)-$(date +%Y%m%d)\"," /usr/lib/os-release