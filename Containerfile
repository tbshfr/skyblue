ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST

FROM ${BASE_IMAGE}@${BASE_IMAGE_DIGEST}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/
COPY --chmod=755 build/scripts/ /tmp/scripts/

# split vscode and chromium into separate layers, vscode updates less frequently than chromium
RUN dnf5 install -y code
RUN dnf5 install -y chromium

# https://fedoraproject.org/wiki/Changes/Modular_GnuPG_Packaging
RUN dnf5 install -y gnupg2-scdaemon

RUN /tmp/scripts/01-install-multimedia.sh

RUN /tmp/scripts/02-install-flatpack.sh && \
    /tmp/scripts/08-enable-services.sh && \
    /tmp/scripts/09-other.sh

RUN /tmp/scripts/98-build-initramfs.sh

RUN /tmp/scripts/99-cleanup-repos.sh && \
    rm -rf /tmp/* \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/log/* /var/tmp/* \
    && rpm-ostree cleanup -m \
    && ostree container commit
