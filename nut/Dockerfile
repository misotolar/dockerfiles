FROM debian:bookworm-slim AS build

LABEL maintainer="michal@sotolar.com"

ARG VERSION=2.8.2
ARG RELEASE=1
ARG SHA256=e4b4b0cbe7dd39ba9097be7f7d787bb2fffbe35df64dff53b5fe393d659c597d
ADD https://github.com/networkupstools/nut/releases/download/v$VERSION/nut-$VERSION.tar.gz /build/nut.tar.gz

ARG DEBIAN_VERSION=2.8.1-3
ARG DEBIAN_SHA256=22fe417539de45c5e66ae4affd6772bb8c15e8284cbdad0aed9c7bd302fc0361
ADD https://salsa.debian.org/debian/nut/-/archive/debian/$DEBIAN_VERSION/nut-debian-$DEBIAN_VERSION.tar.gz /build/debian.tar.gz

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
    echo "$SHA256 */build/nut.tar.gz" | sha256sum -c -; \
    tar xf /build/nut.tar.gz --strip-components=1; \
    echo "$DEBIAN_SHA256 */build/debian.tar.gz" | sha256sum -c -; \
    tar xf /build/debian.tar.gz nut-debian-$DEBIAN_VERSION/debian --strip-components=1; \
    sed -i '/^0004-scripts-python-app-NUT-Monitor-NEWS.adoc-fix-typo-qt.patch/ s/./#&/' debian/patches/series; \
    sed -i '/^0005-Set-the-DesktopFileName-in-scripts-python-app-NUT-Mo.patch/ s/./#&/' debian/patches/series; \
    sed -i '/^data\/html\/README/ s/$/.adoc/' debian/nut-cgi.docs; \
    dch -v $VERSION-$RELEASE+misotolar "Upstream $VERSION release"; \
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
