#!/usr/bin/env bash
set -eux -o pipefail

KARGS=(
    "ia32_emulation=0"  # disables 32 bit support
    "slab_nomerge"
    "init_on_free=1"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "pti=on"
    "randomize_kstack_offset=on"
    "vsyscall=none"
    # "debugfs=off"
    # "oops=panic"
    # "module.sig_enforce=1" # https://www.kernel.org/doc/html/latest/admin-guide/module-signing.html
    "lockdown=confidentiality"
    "quiet loglevel=0"
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


for karg in "${KARGS[@]}"; do
    rpm-ostree kargs --append-if-missing="$karg"
done