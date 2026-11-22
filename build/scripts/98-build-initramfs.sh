#!/usr/bin/bash
set -eux -o pipefail

mapfile -t kernels < <(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
if (( ${#kernels[@]} != 1 )); then
  echo "Expected exactly one kernel in /usr/lib/modules, found ${#kernels[@]}: ${kernels[*]}" >&2
  exit 1
fi
KERNEL="${kernels[0]}"

conf_file="$(mktemp /etc/dracut.conf.d/loglevels.XXXXXX.conf)"

printf '%s\n' \
  "stdloglvl=4" \
  "sysloglvl=0" \
  "kmsgloglvl=0" \
  "fileloglvl=0" \
  > "$conf_file"

/usr/bin/dracut \
    --kver "${KERNEL}" \
    --force \
    --add 'ostree' \
    --no-hostonly \
    --reproducible \
    "/lib/modules/${KERNEL}/initramfs.img"

rm -- "${conf_file}"

chmod 0600 "/lib/modules/${KERNEL}/initramfs.img"
