FROM debian:bookworm-slim AS build

LABEL maintainer="michal@sotolar.com"

ARG VERSION=2.8.1
ARG RELEASE=3.1
ARG SHA256=7da48ee23b1f0d8d72560bb0af84f5c5ae4dbe35452b84cb49840132e47f099c
ADD http://deb.debian.org/debian/pool/main/n/nut/nut_$VERSION.orig.tar.gz /build/nut_$VERSION.orig.tar.gz
ARG DEBIAN_SHA256=5f7a2618dabec45166ea06f94c1c91eb34f03fafdc63d6540827a6ed564fd878
ADD http://deb.debian.org/debian/pool/main/n/nut/nut_$VERSION-$RELEASE.debian.tar.xz /build/nut_$VERSION-$RELEASE.debian.tar.xz

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/nut-$VERSION

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
    echo "$SHA256 */build/nut_$VERSION.orig.tar.gz" | sha256sum -c -; \
    tar xf /build/nut_$VERSION.orig.tar.gz --strip-components=1; \
    echo "$DEBIAN_SHA256 */build/nut_$VERSION-$RELEASE.debian.tar.xz" | sha256sum -c -; \
    tar xf /build/nut_$VERSION-$RELEASE.debian.tar.xz; \
    dch -v $VERSION-$RELEASE+misotolar "Backport $VERSION-$RELEASE release"; \
    dpkg-buildpackage -us -uc -b -d; \
    ls -las ../

FROM alpine:3.19

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/*.deb /build/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY upgrade.sh /usr/local/bin/upgrade.sh

RUN set -ex; \
    ls -las /build

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
