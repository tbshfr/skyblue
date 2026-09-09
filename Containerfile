ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST

FROM ${BASE_IMAGE}@${BASE_IMAGE_DIGEST}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/
COPY build/config/ /tmp/config/
COPY --chmod=755 build/scripts/ /tmp/scripts/

RUN /tmp/scripts/01-install-multimedia.sh
RUN /tmp/scripts/05-install-packages.sh
RUN /tmp/scripts/06-add-binaries.sh

RUN /tmp/scripts/02-install-flatpack.sh && \
    /tmp/scripts/07-add-fonts.sh && \
    /tmp/scripts/08-enable-services.sh && \
    /tmp/scripts/09-other.sh

RUN /tmp/scripts/98-build-initramfs.sh

RUN /tmp/scripts/99-cleanup-repos.sh && \
    rm -rf /tmp/* \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/log/* /var/tmp/* \
    && rpm-ostree cleanup -m \
    && ostree container commit
