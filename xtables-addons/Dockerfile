FROM debian:bullseye-slim AS build

ARG VERSION=3.22
ARG RELEASE=1
ARG DEBIAN_VERSION=3.13-1+deb11u1
ARG DEBIAN_TESTING_VERSION=$VERSION-1

ARG XTABLES_URL=https://inai.de/files/xtables-addons/xtables-addons-$VERSION.tar.xz
ARG XTABLES_SHA256=faa16a27166275afbfe8df605f55c3a81ac693bf19da674d45ceded4137ae217
ARG XTABLES_DEBIAN_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$DEBIAN_VERSION.debian.tar.xz
ARG XTABLES_DEBIAN_SHA256=45b5ab447d937efab14e95e751f2868b55f2f657109422f3af8a55bcd85e86ed
ARG XTABLES_DEBIAN_TESTING_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$DEBIAN_TESTING_VERSION.debian.tar.xz
ARG XTABLES_DEBIAN_TESTING_SHA256=3c883c1a0e17834a08613ef67a2aa4f8e34492e678ec29f0ff8369831d4caa52

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

FROM alpine:3.17

LABEL maintainer="michal@sotolar.com"

WORKDIR /build

COPY --from=build /build/xtables-addons*.deb /build/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]