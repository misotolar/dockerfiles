ARG DOTNET_VERSION=6.0
ARG ALPINE_VERSION=3.17

FROM mcr.microsoft.com/dotnet/sdk:$DOTNET_VERSION-alpine$ALPINE_VERSION AS build

ARG VERSION=10.8.12
ARG URL=https://github.com/jellyfin/jellyfin.git

ARG DOTNET_CLI_TELEMETRY_OPTOUT=1

WORKDIR /tmp/jellyfin

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        git \
    ; \
    git clone --branch v$VERSION --depth=1 -c advice.detachedHead=false $URL /tmp/jellyfin; \
    dotnet publish \
        Jellyfin.Server \
        --configuration Release \
        --self-contained \
        --runtime alpine-x64 \
        --disable-parallel \
        --output=/tmp/jellyfin/dist \
        "-p:DebugSymbols=false" \
        "-p:DebugType=none" \
    ; \
    apk del --no-network .build-deps; \
    mv /tmp/jellyfin/dist /dist; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

FROM node:lts-alpine$ALPINE_VERSION AS build_web

ARG VERSION=10.8.12
ARG SHA256=1c2673ff32df57cd65d0190a053154a6d8b6fcc67d9ff4b7e167fab3ba731f9d
ADD https://github.com/jellyfin/jellyfin-web/archive/refs/tags/v$VERSION.tar.gz /tmp/jellyfin-web.tar.gz

WORKDIR /tmp/jellyfin-web

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        alpine-sdk \
        autoconf \
        automake \
        curl \
        g++ \
        gcc \
        git \
        libtool \
        libpng-dev \
        make \
        musl-dev \
        nasm \
        python3 \
        zlib \
        zlib-dev \
    ; \
    echo "$SHA256  ../jellyfin-web.tar.gz" | sha256sum -c -; \
    tar xf ../jellyfin-web.tar.gz --strip-components=1; \
    npm ci --no-audit --unsafe-perm; \
    apk del --no-network .build-deps; \
    mv /tmp/jellyfin-web/dist /dist; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

FROM alpine:$ALPINE_VERSION

LABEL mantainer="michal@sotolar.com"

ENV JELLYFIN_CONFIG_DIR=/config/config
ENV JELLYFIN_DATA_DIR=/config/data
ENV JELLYFIN_LOG_DIR=/config/log
ENV JELLYFIN_CACHE_DIR=/config/cache
ENV JELLYFIN_WEB_DIR=/usr/share/jellyfin-web

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN set -ex; \
    apk add --no-cache --upgrade \
        fontconfig \
        gcompat \
        icu-libs \
        libssl1.1 \
        libstdc++ \
        libintl \
    ; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY --from=build /dist /usr/lib/jellyfin
COPY --from=build_web /dist /usr/share/jellyfin-web

EXPOSE 8096 8920 7359/udp 1900/udp
VOLUME /config /media
