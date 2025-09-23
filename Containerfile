ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST

FROM ${BASE_IMAGE}@${BASE_IMAGE_DIGEST}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/
COPY --chmod=755 build/scripts/ /tmp/scripts/

RUN <<-EOT sh
    set -euo pipefail
    if ls /tmp/scripts/*.sh 1> /dev/null 2>&1; then
        for script in /tmp/scripts/*.sh; do
            echo "Executing: $script"
            bash "$script" || { echo "Script $script failed with exit code $?"; exit 1; }
        done
    else
        echo "No scripts found in /tmp/scripts/"
        exit 1
    fi
EOT

RUN rm -rf /tmp/* \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/log/* /var/tmp/* \
    && rpm-ostree cleanup -m \
    && ostree container commit
