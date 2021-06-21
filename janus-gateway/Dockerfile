FROM alpine:3.13

LABEL maintainer="michal@sotolar.com"

ARG VERSION=0.11.3
ARG SHA256=bfe4bb0f5c1db7ca1ab7e294b377d604b21e5187a35a64ed93536e2da9f0e9db
ARG URL=https://github.com/meetecho/janus-gateway/archive/refs/tags/v${VERSION}.tar.gz

ARG BORINGSSL_VERSION=chromium-stable
ARG BORINGSSL_SHA256=0cfe2da3bc9999b11d01220570c7b3e6c4eb5e85c28c229cea7412e41a0ef430
ARG BORINGSSL_URL=https://github.com/google/boringssl/archive/refs/heads/${BORINGSSL_VERSION}.tar.gz

ARG LIBNICE_VERSION=0.1.17
ARG LIBNICE_SHA256=47f6b4f4fe2a606e795e06225540f838ad39fa01d7333b8d4f723297860ca8b6
ARG LIBNICE_URL=https://github.com/libnice/libnice/archive/refs/tags/${LIBNICE_VERSION}.tar.gz

ARG LIBSRTP_VERSION=2.3.0
ARG LIBSRTP_SHA256=94093a5d04c5f4743e8d81182b76938374df6d393b45322f24960d250b0110e8
ARG LIBSRTP_URL=https://github.com/cisco/libsrtp/archive/refs/tags/v${LIBSRTP_VERSION}.tar.gz

ARG USRSCTP_VERSION=0.9.5.0
ARG USRSCTP_SHA256=260107caf318650a57a8caa593550e39bca6943e93f970c80d6c17e59d62cd92
ARG USRSCTP_URL=https://github.com/sctplab/usrsctp/archive/refs/tags/${USRSCTP_VERSION}.tar.gz

ARG LIBWEBSOCKETS_VERSION=4.2.0
ARG LIBWEBSOCKETS_SHA256=a57e9a4765dbcd4d880feba8089b43ed69995eaf10d5d61a07981d9ddd975f40
ARG LIBWEBSOCKETS_URL=https://github.com/warmcat/libwebsockets/archive/refs/tags/v${LIBWEBSOCKETS_VERSION}.tar.gz

ARG SOFIASIP_VERSION=1.12.11
ARG SOFIASIP_SHA256=2b01bc2e1826e00d1f7f57d29a2854b15fd5fe24695e47a14a735d195dd37c81
ARG SOFIASIP_URL=https://sourceforge.net/projects/sofia-sip/files/sofia-sip/${SOFIASIP_VERSION}/sofia-sip-${SOFIASIP_VERSION}.tar.gz/download

ADD patches/sofia-sip/*.patch /patches/sofia-sip/

WORKDIR /build

RUN set -ex; \
    apk add --no-cache \
        tzdata; \
    apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        cmake \
        curl \
        g++ \
        gcc \
        gengetopt \
        git \
        go \
        gtk-doc \
        file \
        libtool \
        make \
        patch \
        pkgconfig \
        rsync \
        \
        curl-dev \
        ffmpeg-dev \
        glib-dev \
        jansson-dev \
        libconfig-dev \
        libmicrohttpd-dev \
        libogg-dev \
        libunwind-dev \
        opus-dev \
        openssl-dev \
        zlib-dev; \
    \
    curl -fsSL -o boringssl.tar.gz $BORINGSSL_URL; \
    echo "$BORINGSSL_SHA256 *boringssl.tar.gz" | sha256sum -c -; \
    tar -xf boringssl.tar.gz --strip-components=1; \
    sed -i s/" -Werror"//g CMakeLists.txt; \
    mkdir build; \
    cd build; \
    cmake \
        -DCMAKE_CXX_FLAGS="-lrt" \
        ..; \
    make; \
    mkdir -p /opt/boringssl/lib; \
    cp -R ../include /opt/boringssl; \
    cp ssl/libssl.a /opt/boringssl/lib; \
    cp crypto/libcrypto.a /opt/boringssl/lib; \
    cd /build; \
    rm -rf /build/*; \
    \
    curl -fsSL -o libnice.tar.gz $LIBNICE_URL; \
    echo "$LIBNICE_SHA256 *libnice.tar.gz" | sha256sum -c -; \
    tar -xf libnice.tar.gz --strip-components=1; \
    ./autogen.sh \
        --disable-gtk-doc-html \
        --with-crypto-library=openssl; \
    make; \
    make install; \
    rm -rf /build/*; \
    \
    curl -fsSL -o libsrtp.tar.gz $LIBSRTP_URL; \
    echo "$LIBSRTP_SHA256 *libsrtp.tar.gz" | sha256sum -c -; \
    tar -xf libsrtp.tar.gz --strip-components=1; \
    ./configure \
        --enable-openssl; \
    make shared_library; \
    make install; \
    rm -rf /build/*; \
    \
    curl -fsSL -o usrsctp.tar.gz $USRSCTP_URL; \
    echo "$USRSCTP_SHA256 *usrsctp.tar.gz" | sha256sum -c -; \
    tar -xf usrsctp.tar.gz --strip-components=1; \
    ./bootstrap; \
    ./configure \
        --disable-programs \
        --disable-inet \
        --disable-inet6; \
    make; \
    make install; \
    rm -rf /build/*; \
    \
    curl -fsSL -o libwebsockets.tar.gz $LIBWEBSOCKETS_URL; \
    echo "$LIBWEBSOCKETS_SHA256 *libwebsockets.tar.gz" | sha256sum -c -; \
    tar -xf libwebsockets.tar.gz --strip-components=1; \
    mkdir build; \
    cd build; \
    cmake \
        -DLWS_IPV6=1 \
        -DLWS_MAX_SMP=1 \
        -DLWS_WITH_HTTP2=1 \
        -DLWS_WITHOUT_EXTENSIONS=0 \
        -DLWS_WITHOUT_TESTAPPS=1 \
        -DCMAKE_C_FLAGS="-fpic" \
        ..; \
    make; \
    make install; \
    cd /build; \
    rm -rf /build/*; \
    \
    curl -fsSL -o sofia-sip.tar.gz $SOFIASIP_URL; \
    echo "$SOFIASIP_SHA256 *sofia-sip.tar.gz" | sha256sum -c -; \
    tar xf sofia-sip.tar.gz --strip-components=1; \
    cat /patches/sofia-sip/*.patch | patch -p1; \
    ./configure; \
    make; \
    make install; \
    rm -rf /build/*; \
    \
    curl -fsSL -o janus.tar.gz $URL; \
    echo "$SHA256 *janus.tar.gz" | sha256sum -c -; \
    tar -xf janus.tar.gz --strip-components=1; \
    sh autogen.sh; \
    ./configure \
        --prefix=/opt/janus \
        --disable-docs \
        --disable-gelf-event-handler \
        --disable-sample-event-handler \
        --disable-unix-sockets \
        --enable-boringssl \
        --enable-dtls-settimeout \
        --enable-post-processing; \
    make; \
    make install; \
    make configs; \
    rm -rf /build/*; \
    \
    ln -s /opt/janus/bin/janus /usr/local/bin/janus; \
    mv /opt/janus/etc/janus /etc/; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /opt/janus \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .janus-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    \
    rm -rf \
        /build \
        /patches \
        /opt/janus/etc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

WORKDIR /

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/janus", "--configs-folder=/etc/janus"]