#!/usr/bin/env bash
set -eux -o pipefail

systemctl enable dconf-update.service
systemctl enable apply-kargs.service
systemctl enable rpm-ostreed-automatic.timer

systemctl mask rpm-ostree-countme.timer

# no printing, mDNS discovery or cellular modems needed
systemctl mask \
    avahi-daemon.service avahi-daemon.socket \
    cups.service cups.socket cups.path cups-browsed.service \
    ModemManager.service

# Fedoras default FedoraWorkstation zone accepts all inbound traffic on ports 1025-65535
firewall-offline-cmd --set-default-zone=skyblue
