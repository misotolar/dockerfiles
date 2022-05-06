FROM alpine:3.14 as build

ARG MEDIASDK_VERSION=22.3.0
ARG MEDIASDK_SHA256=e1e74229f409e969b70c2b35b1955068de3d40db85ecc42bd6ff501468bc76d7
ADD https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-$MEDIASDK_VERSION.tar.gz /tmp/mediasdk.tar.gz

ARG FFMPEG_VERSION=5.0.1
ARG FFMPEG_SHA256=28df33d400a1c1c1b20d07a99197809a3b88ef765f5f07dc1ff067fac64c59d6
ADD https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2 /tmp/ffmpeg.tar.bz2

ARG JELLYFIN_FFMPEG_VERSION=$FFMPEG_VERSION-3
ARG JELLYFIN_FFMPEG_SHA256=9d51093d4698d24a35012014f712254cf811b6c1931fc6fa0dfd648f3131e039
ADD https://github.com/jellyfin/jellyfin-ffmpeg/archive/refs/tags/v$JELLYFIN_FFMPEG_VERSION.tar.gz /tmp/jellyfin-ffmpeg.tar.gz

ARG LD_LIBRARY_PATH=/opt/intel/mediasdk/lib:/usr/local/lib:/usr/lib:/lib
ARG PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
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
        g++ \
        ffmpeg-libs \
        ffmpeg-dev \
        libva-dev \
        intel-media-driver-dev \
        musl;

WORKDIR /tmp/mediasdk

RUN set -ex; \
    echo "$MEDIASDK_SHA256  ../mediasdk.tar.gz" | sha256sum --status -c -; \
    tar xf ../mediasdk.tar.gz --strip-components=1; \
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

WORKDIR /tmp/jellyfin-ffmpeg

RUN set -ex; \
    echo "$JELLYFIN_FFMPEG_SHA256 ../jellyfin-ffmpeg.tar.gz" | sha256sum --status -c -; \
    tar xf ../jellyfin-ffmpeg.tar.gz --strip-components=1

WORKDIR /tmp/ffmpeg

RUN set -ex; \
    echo "$FFMPEG_SHA256  ../ffmpeg.tar.bz2" | sha256sum --status -c -; \
    tar xf ../ffmpeg.tar.bz2 --strip-components=1; \
    cat ../jellyfin-ffmpeg/debian/patches/*.patch | patch -p1; \
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

FROM misotolar/jellyfin-server:d330ba81

LABEL mantainer="michal@sotolar.com"

ENV LD_LIBRARY_PATH=/opt/intel/mediasdk/lib:/usr/local/lib:/usr/lib:/lib

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
