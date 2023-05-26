FROM alpine:3.17

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.1.4
ARG SHA256=292397ee925b957fec3e946b8b40d559fcdfc80d171ab9618f10df0e1ebe800f
ADD https://github.com/meetecho/janus-gateway/archive/refs/tags/v${VERSION}.tar.gz /tmp/janus-gateway.tar.gz

ARG BORINGSSL_VERSION=ca1690e221677cea3fb946f324eb89d846ec53f2
ARG BORINGSSL_SHA256=8d21f45a0f0d7dfb7852312c391ebcfcb5e9a476954b51dc27b0c6c0d8768ecd
ADD https://github.com/google/boringssl/archive/${BORINGSSL_VERSION}.tar.gz /tmp/boringssl.tar.gz

ARG LIBNICE_VERSION=0.1.21
ARG LIBNICE_SHA256=0f0d9a6b21cfb512593eacbba2a1981a3ba493341dd7377298085d47954b4ba4
ADD https://gitlab.freedesktop.org/libnice/libnice/-/archive/${LIBNICE_VERSION}/libnice-${LIBNICE_VERSION}.tar.gz /tmp/libnice.tar.gz

ARG LIBSRTP_VERSION=2.5.0
ARG LIBSRTP_SHA256=8a43ef8e9ae2b665292591af62aa1a4ae41e468b6d98d8258f91478735da4e09
ADD https://github.com/cisco/libsrtp/archive/refs/tags/v${LIBSRTP_VERSION}.tar.gz /tmp/libsrtp.tar.gz

ARG USRSCTP_VERSION=0.9.5.0
ARG USRSCTP_SHA256=260107caf318650a57a8caa593550e39bca6943e93f970c80d6c17e59d62cd92
ADD https://github.com/sctplab/usrsctp/archive/refs/tags/${USRSCTP_VERSION}.tar.gz /tmp/usrsctp.tar.gz

ARG LIBWEBSOCKETS_VERSION=4.3.2
ARG LIBWEBSOCKETS_SHA256=6a85a1bccf25acc7e8e5383e4934c9b32a102880d1e4c37c70b27ae2a42406e1
ADD https://github.com/warmcat/libwebsockets/archive/refs/tags/v${LIBWEBSOCKETS_VERSION}.tar.gz /tmp/libwebsockets.tar.gz

ARG SOFIASIP_VERSION=1.13.15
ARG SOFIASIP_SHA256=846b3d5eef57702e8d18967070b538030252116af1500f4baa78ad068c5fdd64
ADD https://github.com/freeswitch/sofia-sip/archive/refs/tags/v${SOFIASIP_VERSION}.tar.gz /tmp/sofia-sip.tar.gz

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
    sh autogen.sh; \
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