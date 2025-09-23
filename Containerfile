ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST

FROM ${BASE_IMAGE}@${BASE_IMAGE_DIGEST}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/
# https://github.com/toolbx-images/images/blob/main/quay.io-toolbx-images.pub
COPY build/keys/quay.io-toolbx-images.pub /etc/pki/containers/
COPY --chmod=755 build/scripts/build.sh /tmp/build.sh

RUN bash /tmp/build.sh

RUN rm -rf /tmp/* \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/log/* /var/tmp/* \
    && rpm-ostree cleanup -m \
    && ostree container commit
