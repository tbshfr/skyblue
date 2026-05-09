#!/usr/bin/env bash
set -eux -o pipefail

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-2020

cd /tmp
FEDORA_VERSION=$(rpm -E %fedora)

# use primary download mirror, others are out of date, see https://bugzilla.rpmfusion.org/show_bug.cgi?id=7447
wget https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm

rpm -K "rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"
rpm -i "rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm"

cd -

dnf5 config-manager setopt fedora-cisco-openh264.enabled=1

# https://rpmfusion.org/Howto/Multimedia

# Switch to full ffmpeg
dnf5 swap ffmpeg-free ffmpeg --allowerasing -y

# Install additional codec
dnf5 install \
  gstreamer1-plugin-libav \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-ugly \
  gstreamer1-vaapi \
  --setopt="install_weak_deps=False" \
  -y

# Hardware Accelerated Codec AMD (mesa)
dnf5 install mesa-va-drivers-freeworld -y
