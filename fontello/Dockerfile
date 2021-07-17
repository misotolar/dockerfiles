FROM node:14-buster-slim AS ttfautohint_build

ARG VERSION=1.8.3.1
ARG URL=https://github.com/source-foundry/ttfautohint-build.git

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/ttfautohint

RUN set -ex; \
    echo "deb http://deb.debian.org/debian buster main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        gcc \
        g++ \
        git \
        libc6-dev \
        make \
        xz-utils; \
    git clone --depth 10 -b v$VERSION -c advice.detachedHead=false $URL /build/ttfautohint; \
    make

FROM node:14-buster-slim AS build

ARG VERSION=e2689251690c53774cde12a843f7d1c6c028ad12
ARG URL=https://github.com/fontello/fontello.git

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ARG NODE_ENV=production
ARG NODECA_ENV=production

WORKDIR /build

RUN set -ex; \
    echo "deb http://deb.debian.org/debian buster main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        git; \
    git clone --depth=10 -b master $URL /build; \
    git checkout -q $VERSION; \
    npm i; \
    /build/server.js assets; \
    rm -rf /build/.git

FROM node:14-buster-slim

LABEL mantainer="michal@sotolar.com"

ENV NODECA_ENV=production

WORKDIR /usr/local/fontello

COPY --from=ttfautohint_build /root/ttfautohint-build/local /usr
COPY --from=build /build /usr/local/fontello

RUN set -ex; \
    echo "deb http://deb.debian.org/debian buster main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        tzdata; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /usr/share/doc/* \
        /usr/share/icons/* \
        /usr/share/man/* \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/fontello/server.js"]