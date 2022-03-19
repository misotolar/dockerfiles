FROM alpine:3.15

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.0.0
ARG SHA256=8b126f554c416767b2aa4c5fe957bfd3ba9326369cf05b312ceca96cd715c310
ADD https://github.com/meetecho/janus-gateway/archive/refs/tags/v${VERSION}.tar.gz /tmp/janus-gateway.tar.gz

ARG BORINGSSL_VERSION=chromium-stable
ARG BORINGSSL_SHA256=e8cd8caba44d8630d4c221ce79a130d6e67e5a7d3e01135f6b45a6a9c72bb51f
ADD https://github.com/google/boringssl/archive/refs/heads/${BORINGSSL_VERSION}.tar.gz /tmp/boringssl.tar.gz

ARG LIBNICE_VERSION=0.1.18
ARG LIBNICE_SHA256=8bacba53e59ec6d72e9a398835c4df6446d5e0d71b2dabb7a19f6d6c5a72dcbe
ADD https://gitlab.com/libnice/libnice/-/archive/${LIBNICE_VERSION}/libnice-${LIBNICE_VERSION}.tar.gz /tmp/libnice.tar.gz

ARG LIBSRTP_VERSION=2.3.0
ARG LIBSRTP_SHA256=94093a5d04c5f4743e8d81182b76938374df6d393b45322f24960d250b0110e8
ADD https://github.com/cisco/libsrtp/archive/refs/tags/v${LIBSRTP_VERSION}.tar.gz /tmp/libsrtp.tar.gz

ARG USRSCTP_VERSION=0.9.5.0
ARG USRSCTP_SHA256=260107caf318650a57a8caa593550e39bca6943e93f970c80d6c17e59d62cd92
ADD https://github.com/sctplab/usrsctp/archive/refs/tags/${USRSCTP_VERSION}.tar.gz /tmp/usrsctp.tar.gz

ARG LIBWEBSOCKETS_VERSION=4.3.1
ARG LIBWEBSOCKETS_SHA256=8fdb1454a1b34cd9a6351beaab237a485e6853806101de7e62bd2bc250bb50af
ADD https://github.com/warmcat/libwebsockets/archive/refs/tags/v${LIBWEBSOCKETS_VERSION}.tar.gz /tmp/libwebsockets.tar.gz

ARG SOFIASIP_VERSION=1.12.11
ARG SOFIASIP_SHA256=2b01bc2e1826e00d1f7f57d29a2854b15fd5fe24695e47a14a735d195dd37c81
ADD https://sourceforge.net/projects/sofia-sip/files/sofia-sip/${SOFIASIP_VERSION}/sofia-sip-${SOFIASIP_VERSION}.tar.gz/download /tmp/sofia-sip.tar.gz

ADD patches/sofia-sip/*.patch /tmp/patches/sofia-sip/

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        cmake \
        g++ \
        gcc \
        gengetopt \
        git \
        go \
        gtk-doc \
        file \
        libtool \
        meson \
        make \
        patch \
        pkgconfig \
        rsync \
        samurai \
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
    echo "$BORINGSSL_SHA256 */tmp/boringssl.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/boringssl.tar.gz --strip-components=1; \
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
    \
    cd /build; \
    rm -rf /build/*; \
    \
    echo "$LIBNICE_SHA256 */tmp/libnice.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/libnice.tar.gz --strip-components=1; \
    meson build; \
    meson configure build \
        -Dcrypto-library=openssl \
        -Dexamples=disabled \
        -Dgtk_doc=disabled; \
    ninja -C build; \
    ninja -C build install; \
    \
    rm -rf /build/*; \
    \
    echo "$LIBSRTP_SHA256 */tmp/libsrtp.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/libsrtp.tar.gz --strip-components=1; \
    ./configure \
        --enable-openssl; \
    make shared_library; \
    make install; \
    \
    rm -rf /build/*; \
    \
    echo "$USRSCTP_SHA256 */tmp/usrsctp.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/usrsctp.tar.gz --strip-components=1; \
    ./bootstrap; \
    ./configure \
        --disable-programs \
        --disable-inet \
        --disable-inet6; \
    make; \
    make install; \
    \
    rm -rf /build/*; \
    \
    echo "$LIBWEBSOCKETS_SHA256 */tmp/libwebsockets.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/libwebsockets.tar.gz --strip-components=1; \
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
    \
    cd /build; \
    rm -rf /build/*; \
    \
    echo "$SOFIASIP_SHA256 */tmp/sofia-sip.tar.gz" | sha256sum -c -; \
    tar xf /tmp/sofia-sip.tar.gz --strip-components=1; \
    cat /tmp/patches/sofia-sip/*.patch | patch -p1; \
    ./configure; \
    make; \
    make install; \
    \
    rm -rf /build/*; \
    \
    echo "$SHA256 */tmp/janus-gateway.tar.gz" | sha256sum -c -; \
    tar -xf /tmp/janus-gateway.tar.gz --strip-components=1; \
    sh autogen.sh; \
    ./configure \
        --prefix=/usr/local/janus \
        --disable-all-handlers \
        --disable-all-plugins \
        --disable-all-transports \
        --disable-docs \
        --disable-unix-sockets \
        --enable-boringssl \
        --enable-dtls-settimeout \
        --enable-post-processing \
        --enable-plugin-sip \
        --enable-rest \
        --enable-websockets \
        ; \
    make; \
    make install; \
    make configs; \
    \
    mkdir -p /usr/local/janus/lib/janus/loggers; \
    mv /usr/local/janus/etc/janus /etc/; \
    \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/janus \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .janus-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    \
    rm -rf \
        /build \
        /usr/local/janus/etc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

WORKDIR /

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/local/janus/bin/janus", "--configs-folder=/etc/janus"]