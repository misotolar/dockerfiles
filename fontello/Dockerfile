FROM node:14-bullseye-slim AS build

ARG VERSION=71330f51d11b00fa75b6c516db2ea4d62da67330
ARG SHA256=94abd20c06cd379e8dc6e27982c25ed206ba70de0acd63998f16c30bf6ff277e
ADD https://github.com/fontello/fontello/archive/$VERSION.tar.gz /build/fontello.tar.gz

ARG TTFAUTOHINT_VERSION=1.8.3.1
ARG TTFAUTOHINT_SHA256=a75ac521488ef131584c26b66bb05a3d8eef7844e251f44e411be88814b86ca1
ADD https://github.com/source-foundry/ttfautohint-build/archive/refs/tags/v$TTFAUTOHINT_VERSION.tar.gz /build/ttfautohint.tar.gz

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/fontello

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        file \
        g++ \
        gcc \
        git \
        libc6-dev \
        make \
        xz-utils \
    ; \
    echo "$SHA256  ../fontello.tar.gz" | sha256sum --status -c -; \
    tar xf ../fontello.tar.gz --strip-components=1; \
    npm i; \
    node server.js assets

WORKDIR /build/ttfautohint

RUN set -ex; \
    echo "$TTFAUTOHINT_SHA256  ../ttfautohint.tar.gz" | sha256sum --status -c -; \
    tar xf ../ttfautohint.tar.gz --strip-components=1; \
    make

FROM node:14-bullseye-slim

LABEL mantainer="michal@sotolar.com"

ENV NODECA_ENV=production

WORKDIR /usr/local/fontello

COPY --from=build /root/ttfautohint-build/local /usr
COPY --from=build /build/fontello /usr/local/fontello

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
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

ENTRYPOINT ["entrypoint.sh"]
CMD ["node", "/usr/local/fontello/server.js"]