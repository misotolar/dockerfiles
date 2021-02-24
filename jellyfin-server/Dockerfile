ARG DOTNET_VERSION=3.1
ARG ALPINE_VERSION=3.13

FROM mcr.microsoft.com/dotnet/core/sdk:${DOTNET_VERSION}-alpine AS build

ARG VERSION=10.6.4
ARG URL=https://github.com/jellyfin/jellyfin

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        git; \
    git clone --branch v$VERSION --depth=1 -c advice.detachedHead=false $URL /build; \
    dotnet publish \
        --configuration Release \
        --output=/build/dist \
        --self-contained \
        --runtime alpine-x64 \
        "-p:GenerateDocumentationFile=false;DebugSymbols=false;DebugType=none" \
        Jellyfin.Server; \
    apk del --no-network .build-deps; \
    mv /build/dist /dist; \
    rm -rf \
        /build \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

FROM node:current-alpine AS build_web

ARG VERSION=10.6.4
ARG URL=https://github.com/jellyfin/jellyfin-web

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        alpine-sdk \
        autoconf \
        automake \
        curl \
        g++ \
        gcc \
        gifsicle \
        git \
        libtool \
        make \
        musl-dev \
        nasm \
        python2 \
        zlib \
        zlib-dev; \
    git clone --branch v$VERSION --depth=1 -c advice.detachedHead=false $URL /build; \
    yarn install; \
    apk del --no-network .build-deps; \
    mv /build/dist /dist; \
    rm -rf \
        /build \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

FROM alpine:${ALPINE_VERSION}

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
        libintl; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY --from=build /dist /usr/lib/jellyfin
COPY --from=build_web /dist /usr/share/jellyfin-web

EXPOSE 8096 8920 7359/udp 1900/udp
VOLUME /config /media
