#!/bin/bash
set -euo pipefail

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

DELETE_KARGS=()
for old_k in "${APPLIED_KARGS[@]}"; do
    skip=false
    for new_k in "${KARGS[@]}"; do
        if [[ "$old_k" == "$new_k" ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        DELETE_KARGS+=("--delete=$old_k")
    fi
done

ADD_KARGS=()
for new_k in "${KARGS[@]}"; do
    already_applied=false
    for applied_k in "${APPLIED_KARGS[@]}"; do
        if [[ "$new_k" == "$applied_k" ]]; then
            already_applied=true
            break
        fi
    done
    if ! $already_applied; then
        ADD_KARGS+=("--append-if-missing=$new_k")
    fi
done

if [[ ${#DELETE_KARGS[@]} -gt 0 ]] || [[ ${#ADD_KARGS[@]} -gt 0 ]]; then
    ALL_ARGS=()
    if [[ ${#DELETE_KARGS[@]} -gt 0 ]]; then
        ALL_ARGS+=("${DELETE_KARGS[@]}")
    fi
    if [[ ${#ADD_KARGS[@]} -gt 0 ]]; then
        ALL_ARGS+=("${ADD_KARGS[@]}")
    fi

    rpm-ostree kargs "${ALL_ARGS[@]}"

    mkdir -p "$(dirname "$MARKER")"
    {
        printf 'PREV_VERSION=%q\n' "$VERSION"
        printf 'APPLIED_KARGS=('
        for k in "${KARGS[@]}"; do
            printf ' %q' "$k"
        done
        printf ' )\n'
    } > "$MARKER"
else
    echo "No kernel args changes needed - already up to date"
fi

echo "Kernel args updated to version $VERSION."
echo "Please reboot to apply"
