FROM debian:bookworm-slim AS build

LABEL maintainer="michal@sotolar.com"

ARG VERSION=2.8.1
ARG RELEASE=3
ARG SHA256=22fe417539de45c5e66ae4affd6772bb8c15e8284cbdad0aed9c7bd302fc0361
ADD https://salsa.debian.org/debian/nut/-/archive/debian/$VERSION-$RELEASE/nut-debian-$VERSION-$RELEASE.tar.gz /tmp/nut.tar.gz
ARG ORIG_SHA256=7da48ee23b1f0d8d72560bb0af84f5c5ae4dbe35452b84cb49840132e47f099c
ADD http://deb.debian.org/debian/pool/main/n/nut/nut_$VERSION.orig.tar.gz /build/nut_$VERSION.orig.tar.gz

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/nut

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        nut \
    ; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        devscripts \
        ; \
    echo "$SHA256 */tmp/nut.tar.gz" | sha256sum -c -; \
    echo "$ORIG_SHA256 */build/nut_$VERSION.orig.tar.gz" | sha256sum -c -; \
    tar xf /tmp/nut.tar.gz --strip-components=1; \
    dch -v $VERSION-$RELEASE+misotolar "Backport $VERSION release"; \
    dpkg-buildpackage -us -uc --build=all

FROM alpine:3.19

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/nut*.deb /build/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
