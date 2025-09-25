#!/usr/bin/env bash
set -eux -o pipefail

systemctl enable dconf-update.service
systemctl enable apply-kargs.service
systemctl enable rpm-ostreed-automatic.timer