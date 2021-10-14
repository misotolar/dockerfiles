FROM debian:bullseye-slim AS build

ARG MAJOR=5.2
ARG VERSION=$MAJOR.4
ARG URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-$VERSION.tgz
ARG SHA256=46a27256698b682ac94dfdf1a77c9803a9d3599b41d34f14e91491365758a561
ARG URL_CORE=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-core-$VERSION.tgz
ARG SHA256_CORE=6d8a48086df1a019e504f529cbad742d43994a15af2c5a62b5b2147b47e9531c

ARG DEBIAN_VERSION=5.2.3.4-1
ARG DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall/shorewall_$DEBIAN_VERSION.debian.tar.xz
ARG DEBIAN_SHA256=b1760d7d1434739db779f16c9e573dae8e156385c1c000c608429a26e5a12911
ARG DEBIAN_URL_CORE=http://deb.debian.org/debian/pool/main/s/shorewall-core/shorewall-core_$DEBIAN_VERSION.debian.tar.xz
ARG DEBIAN_SHA256_CORE=f5467d0b1d84c82d4dc5f7f4ac68a1cae19df2650c8a1294badac700e3fb5cca

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb-src http://deb.debian.org/debian bullseye main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        shorewall; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        devscripts; \
    curl -fsSL -o /tmp/shorewall.tgz $URL; \
    echo "$SHA256 */tmp/shorewall.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-core.tgz $URL_CORE; \
    echo "$SHA256_CORE */tmp/shorewall-core.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/debian.tar.xz $DEBIAN_URL; \
    echo "$DEBIAN_SHA256 */tmp/debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/debian-core.tar.xz $DEBIAN_URL_CORE; \
    echo "$DEBIAN_SHA256_CORE */tmp/debian-core.tar.xz" | sha256sum -c -; \
    mkdir /build/shorewall; \
    cd /build/shorewall; \
    tar xf /tmp/shorewall.tgz --strip-components=1; \
    tar xf /tmp/debian.tar.xz; \
    dch -v $VERSION-1+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall-core; \
    cd /build/shorewall-core; \
    tar xf /tmp/shorewall-core.tgz --strip-components=1; \
    tar xf /tmp/debian-core.tar.xz; \
    dch -v $VERSION-1+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b

FROM alpine:3.14

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/*.deb /build/

ENTRYPOINT find /build -type f
