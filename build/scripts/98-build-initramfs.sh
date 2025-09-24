#!/usr/bin/bash
set -eux -o pipefail

KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed 's/kernel-//')"

conf_file="$(mktemp /etc/dracut.conf.d/loglevels.XXXXXX.conf)"

printf '%s\n' \
  "stdloglvl=4" \
  "sysloglvl=0" \
  "kmsgloglvl=0" \
  "fileloglvl=0" \
  > "$temp_file"

/usr/bin/dracut \
    --kver "${KERNEL}" \
    --force \
    --add 'ostree' \
    --no-hostonly \
    --reproducible \
    "/lib/modules/${KERNEL}/initramfs.img"

rm -- "${temp_file}"

chmod 0600 "/lib/modules/${KERNEL}/initramfs.img"