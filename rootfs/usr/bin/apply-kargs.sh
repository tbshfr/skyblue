#!/bin/bash
set -eux -o pipefail

VERSION=1
MARKER="/var/lib/script-markers/kargs"

KARGS=(
    "ia32_emulation=0"  # disables 32 bit support
    "slab_nomerge"
    "init_on_free=1"
    "init_on_alloc=1"
    "page_alloc.shuffle=1"
    "pti=on"
    "randomize_kstack_offset=on"
    "vsyscall=none"
    # "debugfs=off"
    # "oops=panic"
    # "module.sig_enforce=1" # https://www.kernel.org/doc/html/latest/admin-guide/module-signing.html
    "lockdown=confidentiality"
    "quiet"
    "loglevel=0"
    "spectre_v2=on"
    "random.trust_cpu=off"
    "iommu=force"
    "iommu.passthrough=0"
    "iommu.strict=1"
    # "mitigations=auto,nosmt"
    "spec_store_bypass_disable=on"
    "l1d_flush=on"
    "rd.shell=0"
    "rd.emergency=halt"
)

PREV_VERSION=0
APPLIED_KARGS=()
if [ -f "$MARKER" ]; then
    source "$MARKER"
fi

if [ "$PREV_VERSION" -ge "$VERSION" ]; then
    echo "Kernel args version $VERSION or higher already applied - skipping"
    exit 0
fi

for old_k in "${APPLIED_KARGS[@]}"; do
    skip=false
    for new_k in "${KARGS[@]}"; do
        if [[ "$old_k" == "$new_k" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        rpm-ostree kargs --delete="$old_k"
    fi
done

for new_k in "${KARGS[@]}"; do
    rpm-ostree kargs --append-if-missing="$new_k"
done

mkdir -p "$(dirname "$MARKER")"
{
    printf 'PREV_VERSION=%q\n' "$VERSION"
    printf 'APPLIED_KARGS=('
    for k in "${KARGS[@]}"; do
        printf ' %q' "$k"
    done
    printf ' )\n'
} > "$MARKER"

echo "Kernel args updated to version $VERSION."
echo "Please reboot to apply"
