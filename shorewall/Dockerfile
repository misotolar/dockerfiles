FROM debian:bullseye-slim AS build

ARG MAJOR=5.2
ARG VERSION=$MAJOR.8
ARG RELEASE=2
ARG DEBIAN_VERSION=5.2.3.4-1

ARG SHOREWALL_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-$VERSION.tgz
ARG SHOREWALL_SHA256=7b5a7e44c62f16dbf18610fe1e47100be48c3505799954c66028ff4c664ec238
ARG SHOREWALL_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall/shorewall_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL_DEBIAN_SHA256=b1760d7d1434739db779f16c9e573dae8e156385c1c000c608429a26e5a12911
ARG SHOREWALL_CORE_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-core-$VERSION.tgz
ARG SHOREWALL_CORE_SHA256=c2aabc8fd28fbaba3a2421bb8c001710efc4c4c21c2e1b90fd876db82724371d
ARG SHOREWALL_CORE_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall-core/shorewall-core_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL_CORE_DEBIAN_SHA256=f5467d0b1d84c82d4dc5f7f4ac68a1cae19df2650c8a1294badac700e3fb5cca
ARG SHOREWALL_INIT_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-init-$VERSION.tgz
ARG SHOREWALL_INIT_SHA256=22ef200747ee9c935eb8b437870129cb75a8fe818a7dc74a1f82dfefb2fcaf5a
ARG SHOREWALL_INIT_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall-init/shorewall-init_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL_INIT_DEBIAN_SHA256=cedd931eefca44303f2daf84daa7d0a1d39176c106ee946423e6ad07157bec45
ARG SHOREWALL_LITE_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall-lite-$VERSION.tgz
ARG SHOREWALL_LITE_SHA256=d53dc4c645cf21d92d5143d080b5053915822cf31cee6c30b167a817147e06d8
ARG SHOREWALL_LITE_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall-lite/shorewall-lite_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL_LITE_DEBIAN_SHA256=b8e2286469e6afb1350282ca95e98a425488579dd8adc88978961ced6f2383ec
ARG SHOREWALL6_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall6-$VERSION.tgz
ARG SHOREWALL6_SHA256=f9cb82ef0af1a3ee80c1e9a130e2835996b332db9a6baf590a9a422df07f5196
ARG SHOREWALL6_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall6/shorewall6_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL6_DEBIAN_SHA256=3c302e5a20fe8733517f0e41d7bfd079b31fc3d4314d43e4249b20cf480c1eee
ARG SHOREWALL6_LITE_URL=https://shorewall.org/pub/shorewall/$MAJOR/shorewall-$VERSION/shorewall6-lite-$VERSION.tgz
ARG SHOREWALL6_LITE_SHA256=5d1e690cfd81c6f3591236a0902aac1d84e47f6ad9f2d04914db61d79786d182
ARG SHOREWALL6_LITE_DEBIAN_URL=http://deb.debian.org/debian/pool/main/s/shorewall6-lite/shorewall6-lite_$DEBIAN_VERSION.debian.tar.xz
ARG SHOREWALL6_LITE_DEBIAN_SHA256=8d5150ef8c209d6523f146ca5cf8a90c81c45de3f626837049f9b36ab639ccc9

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
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
    curl -fsSL -o /tmp/shorewall.tgz $SHOREWALL_URL; \
    echo "$SHOREWALL_SHA256 */tmp/shorewall.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-debian.tar.xz $SHOREWALL_DEBIAN_URL; \
    echo "$SHOREWALL_DEBIAN_SHA256 */tmp/shorewall-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-core.tgz $SHOREWALL_CORE_URL; \
    echo "$SHOREWALL_CORE_SHA256 */tmp/shorewall-core.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-core-debian.tar.xz $SHOREWALL_CORE_DEBIAN_URL; \
    echo "$SHOREWALL_CORE_DEBIAN_SHA256 */tmp/shorewall-core-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-init.tgz $SHOREWALL_INIT_URL; \
    echo "$SHOREWALL_INIT_SHA256 */tmp/shorewall-init.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-init-debian.tar.xz $SHOREWALL_INIT_DEBIAN_URL; \
    echo "$SHOREWALL_INIT_DEBIAN_SHA256 */tmp/shorewall-init-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-lite.tgz $SHOREWALL_LITE_URL; \
    echo "$SHOREWALL_LITE_SHA256 */tmp/shorewall-lite.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall-lite-debian.tar.xz $SHOREWALL_LITE_DEBIAN_URL; \
    echo "$SHOREWALL_LITE_DEBIAN_SHA256 */tmp/shorewall-lite-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall6.tgz $SHOREWALL6_URL; \
    echo "$SHOREWALL6_SHA256 */tmp/shorewall6.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall6-debian.tar.xz $SHOREWALL6_DEBIAN_URL; \
    echo "$SHOREWALL6_DEBIAN_SHA256 */tmp/shorewall6-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall6-lite.tgz $SHOREWALL6_LITE_URL; \
    echo "$SHOREWALL6_LITE_SHA256 */tmp/shorewall6-lite.tgz" | sha256sum -c -; \
    curl -fsSL -o /tmp/shorewall6-lite-debian.tar.xz $SHOREWALL6_LITE_DEBIAN_URL; \
    echo "$SHOREWALL6_LITE_DEBIAN_SHA256 */tmp/shorewall6-lite-debian.tar.xz" | sha256sum -c -; \
    mkdir /build/shorewall; cd /build/shorewall; \
    tar xf /tmp/shorewall.tgz --strip-components=1; \
    tar xf /tmp/shorewall-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall-core; cd /build/shorewall-core; \
    tar xf /tmp/shorewall-core.tgz --strip-components=1; \
    tar xf /tmp/shorewall-core-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall-init; cd /build/shorewall-init; \
    tar xf /tmp/shorewall-init.tgz --strip-components=1; \
    tar xf /tmp/shorewall-init-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall-lite; cd /build/shorewall-lite; \
    tar xf /tmp/shorewall-lite.tgz --strip-components=1; \
    tar xf /tmp/shorewall-lite-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall6; cd /build/shorewall6; \
    tar xf /tmp/shorewall6.tgz --strip-components=1; \
    tar xf /tmp/shorewall6-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b; \
    mkdir /build/shorewall6-lite; cd /build/shorewall6-lite; \
    tar xf /tmp/shorewall6-lite.tgz --strip-components=1; \
    tar xf /tmp/shorewall6-lite-debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b

FROM alpine:3.17

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/shorewall*.deb /build/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]