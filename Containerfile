ARG BASE_IMAGE
ARG BASE_IMAGE_DIGEST

FROM scratch AS ctx
COPY build/config/ /config/
COPY --chmod=755 build/scripts/ /scripts/

FROM ${BASE_IMAGE}@${BASE_IMAGE_DIGEST}

COPY rootfs/ /
COPY cosign.pub /etc/pki/containers/

# use throwaway cache, log and temp dirs for every RUN
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/run/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/01-install-multimedia.sh

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/run/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/05-install-packages.sh

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/06-add-binaries.sh

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/02-install-flatpack.sh && \
    /ctx/scripts/07-add-fonts.sh && \
    /ctx/scripts/08-enable-services.sh && \
    /ctx/scripts/09-other.sh

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/98-build-initramfs.sh

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/var/lib/dnf \
    --mount=type=tmpfs,dst=/run/dnf \
    --mount=type=tmpfs,dst=/var/log \
    --mount=type=tmpfs,dst=/var/tmp \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/scripts/99-cleanup-repos.sh

RUN bootc container lint
