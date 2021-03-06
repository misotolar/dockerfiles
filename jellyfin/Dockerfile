ARG ALPINE_VERSION=3.13

FROM alpine:$ALPINE_VERSION as build

ARG FFMPEG_VERSION=4.4
ARG FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2"
ARG FFMPEG_SHA256=42093549751b582cf0f338a21a3664f52e0a9fbe0d238d3c992005e493607d0e

ARG MEDIASDK_VERSION=21.2.3
ARG MEDIASDK_URL="https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-$MEDIASDK_VERSION.tar.gz"
ARG MEDIASDK_SHA256=7791be83e5e9f6d55f31d6ad9037012fc78b846724644b9db2087d1b7dfec078

ARG LD_LIBRARY_PATH=/opt/intel/mediasdk/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib:/lib
ARG PKG_CONFIG_PATH=/opt/intel/mediasdk/lib64/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
ARG SRC=/usr/local
ARG PREFIX=/usr/local

RUN set -ex; \
    apk add --no-cache \
        autoconf \
        automake \
        alpine-sdk \
        ca-certificates \
        cmake \
        coreutils \
        cunit-dev \
        curl \
        dos2unix \
        libtool \
        nasm \
        python3 \
        tzdata \
        unzip \
        yasm \
        \
        cunit-dev \
        dav1d-dev \
        fdk-aac-dev \
        fontconfig-dev \
        freetype-dev \
        fribidi-dev \
        lame-dev \
        libass-dev \
        libbluray-dev \
        libdrm-dev \
        libogg-dev \
        libpng-dev \
        libtheora-dev \
        libvorbis-dev \
        libvpx-dev \
        libwebp-dev \
        mesa-dev \
        openssl-dev \
        opus-dev \
        util-linux-dev \
        x264-dev \
        x265-dev \
        \
        libva-intel-driver; \
    echo http://dl-2.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories; \
    echo http://dl-2.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories; \
    echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    apk add --no-cache --upgrade \
        gcc \
        ffmpeg-libs \
        ffmpeg-dev \
        libva-dev \
        intel-media-driver-dev \
        musl;

WORKDIR /tmp/mediasdk

RUN set -ex; \
    curl -fsSL -o mediasdk.tar.gz $MEDIASDK_URL; \
    echo "$MEDIASDK_SHA256  mediasdk.tar.gz" | sha256sum --status -c -; \
    tar xf mediasdk.tar.gz --strip-components=1; \
    mkdir build; \
    cd build; \
    cmake \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DENABLE_X11=OFF \
        -DBUILD_SAMPLES=OFF \
        -DBUILD_TUTORIALS=OFF \
        ../; \
    make -j $(nproc); \
    make -j $(nproc) install

ENV CFLAGS="-O2 -pipe -march=x86-64 -mtune=generic"
ENV CXXFLAGS="-O2 -pipe -march=x86-64 -mtune=generic"

WORKDIR /tmp/ffmpeg

ADD patches/jellyfin-ffmpeg/*.patch /tmp/ffmpeg/patches/

RUN set -ex; \
    curl -fsSL -o ffmpeg.tar.bz2 $FFMPEG_URL; \
    echo "$FFMPEG_SHA256  ffmpeg.tar.bz2" | sha256sum --status -c -; \
    tar xf ffmpeg.tar.bz2 --strip-components=1; \
    cat patches/*.patch | patch -p1; \
    ./configure \
        --disable-doc \
        --disable-debug \
        --disable-ffplay \
        --disable-libxcb \
        --disable-sdl2 \
        --disable-xlib \
        --enable-fontconfig \
        --enable-gpl \
        --enable-libass \
        --enable-libbluray \
        --enable-libdav1d \
        --enable-libdrm \
        --enable-libfdk-aac \
        --enable-libfontconfig \
        --enable-libfreetype \
        --enable-libfribidi \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libwebp \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree \
        --enable-openssl \
        --enable-shared \
        --enable-version3 \
        --extra-cflags="-I$PREFIX/include $CFLAGS" \
        --extra-cxxflags="-I$PREFIX/include $CXXFLAGS" \
        --extra-ldflags="-L$PREFIX/lib" \
        --extra-libs="-lpthread -lm" \
        --prefix="$PREFIX" \
        \
        --enable-libmfx \
        --enable-vaapi \
        || (cat ffbuild/config.log ; false); \
    mkdir -p /build$PREFIX/bin/; \
    make -j$(nproc) install tools/qt-faststart; \
    cp tools/qt-faststart /build$PREFIX/bin

WORKDIR /tmp/build
COPY utilities/extractlibrary /tmp/build/extractlibrary

RUN set -ex; \
    echo /usr/local/bin/ffmpeg >> cplist; \
    echo /usr/local/bin/ffprobe >> cplist; \
    ./extractlibrary cplist /build; \
    cp --archive --parents --no-dereference /opt/intel /build

FROM misotolar/jellyfin-server:b1325b49

LABEL mantainer="michal@sotolar.com"

ENV LD_LIBRARY_PATH=/opt/intel/mediasdk/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib:/lib

RUN set -ex; \
    apk add --no-cache --upgrade \
        libva-intel-driver; \
    echo http://dl-2.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories; \
    echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    apk add --no-cache --upgrade \
        intel-media-driver; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY --from=build /build /

ENTRYPOINT /usr/lib/jellyfin/jellyfin --ffmpeg /usr/local/bin/ffmpeg
