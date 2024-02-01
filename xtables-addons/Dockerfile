FROM debian:bookworm-slim AS build

ARG VERSION=3.25
ARG RELEASE=1
ARG DEBIAN_VERSION=3.23-1
ARG DEBIAN_TESTING_VERSION=$VERSION-$RELEASE

ARG XTABLES_URL=https://inai.de/files/xtables-addons/xtables-addons-$VERSION.tar.xz
ARG XTABLES_SHA256=8c9f4c6a8e92eb7cfbf03f4ebcb1e1e793256c2efd0226d83312bfb0ffe14b84
ARG XTABLES_DEBIAN_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$DEBIAN_VERSION.debian.tar.xz
ARG XTABLES_DEBIAN_SHA256=39510359008cb4e38f695bad4f14a0b571ee23e50eb538226d41ce5aa6351315
ARG XTABLES_DEBIAN_TESTING_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$DEBIAN_TESTING_VERSION.debian.tar.xz
ARG XTABLES_DEBIAN_TESTING_SHA256=42a2e1e5db8d6214d33ed87190fbdbedfa20865cf17a3a63b7533b0bf27e6b60

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        xtables-addons; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        devscripts; \
    curl -fsSL -o /tmp/xtables.tar.xz $XTABLES_URL; \
    echo "$XTABLES_SHA256 */tmp/xtables.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/xtables-debian.tar.xz $XTABLES_DEBIAN_URL; \
    echo "$XTABLES_DEBIAN_SHA256 */tmp/xtables-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/xtables-debian-testing.tar.xz $XTABLES_DEBIAN_TESTING_URL; \
    echo "$XTABLES_DEBIAN_TESTING_SHA256 */tmp/xtables-debian-testing.tar.xz" | sha256sum -c -; \
    mkdir /build/xtables; cd /build/xtables; \
    tar xf /tmp/xtables.tar.xz --strip-components=1; \
    tar xf /tmp/xtables-debian.tar.xz; \
    tar xf /tmp/xtables-debian-testing.tar.xz debian/docs; \
    tar xf /tmp/xtables-debian-testing.tar.xz debian/patches; \
    dch -v $VERSION-$RELEASE+misotolar "Backport {$VERSION} release"; \
    dpkg-buildpackage -us -uc -b

FROM alpine:3.18

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/xtables-addons*.deb /build/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]