ARG BUILD_FROM=hassioaddons/base:8.0.6
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
# hadolint ignore=DL3003
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base=0.5-r2 \
        git=2.26.2-r0 \
    \
    && apk add --no-cache \
        libqrencode=4.0.2-r0 \
        openresolv=3.10.0-r0 \
        wireguard-tools=1.0.20200510-r0 \
    \
    && apk del --no-cache --purge \
        .build-dependencies 

# Copy root filesystem
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="WireGuard Client" \
    io.hass.description="Fast, modern, secure VPN tunnel" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Fabio Bigmoby Mauro <https://github.com/bigmoby>" \
    org.opencontainers.image.title="WireGuard Client" \
    org.opencontainers.image.description="Fast, modern, secure VPN tunnel" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Fabio Bigmoby Mauro <https://github.com/bigmoby>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/bigmoby/addon-wireguard" \
    org.opencontainers.image.documentation="https://github.com/bigmoby/addon-wireguard/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
