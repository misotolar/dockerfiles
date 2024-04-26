FROM debian:bookworm-slim AS build

ARG VERSION=d7e58c5a812988c341ec4ad19f79faf067388d58
ARG SHA256=3fbf3a77ace0b86e06a12aae9e83b833ea0ac4114b457bc2388620d9c822374f
ADD https://github.com/ipxe/ipxe/archive/$VERSION.tar.gz /tmp/ipxe.tar.gz

ARG CA_SHA256=0d7547c626d2479deb03455ffc47e563855bb9565d8d3d348ab72d1ee9f87c96
ADD https://ca.ipxe.org/ca.crt /build/certs/ca.pem

ARG ISRGROOT_SHA256=22b557a27055b33606b6559f37703928d3e4ad79f110b407d04986e1843543d1
ADD https://letsencrypt.org/certs/isrgrootx1.pem /build/certs/isrgrootx1.pem

ARG LER3_SHA256=177e1b8fc43b722b393f4200ff4d92e32deeffbb76fef5ee68d8f49c88cf9d32
ADD https://letsencrypt.org/certs/lets-encrypt-r3.pem /build/certs/lets-encrypt-r3.pem

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/ipxe/src

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        ipxe \
    ; \
    apt-get install --no-install-recommends -y \
        openssl \
    ; \
    echo "$SHA256 */tmp/ipxe.tar.gz" | sha256sum -c -; \
    tar xf /tmp/ipxe.tar.gz -C /build/ipxe --strip-components=1; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
