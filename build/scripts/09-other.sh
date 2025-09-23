#!/usr/bin/env bash
set -eux -o pipefail

sed -i "s,^PRETTY_NAME=.*,PRETTY_NAME=\"skyblue (Fedora Linux $(rpm -E %fedora))\"," /usr/lib/os-release