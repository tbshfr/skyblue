ARG FEDORA_MAJOR_VERSION

# switch to official image once they are signed: quay.io/fedora/fedora-silverblue
# see https://discussion.fedoraproject.org/t/quay-io-fedora-fedora-silverblue-39-not-updated/112593/5 
# and https://pagure.io/workstation-ostree-config / https://pagure.io/releng/issue/10399
FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/
COPY --chmod=755 build.sh /tmp/build.sh

RUN bash /tmp/build.sh

RUN rm -rf /tmp/* \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/log/* /var/tmp/* \
    && rpm-ostree cleanup -m \
    && ostree container commit
