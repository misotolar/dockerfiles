FROM alpine:3.16 as build

ARG MEDIASDK_VERSION=22.4.3
ARG MEDIASDK_SHA256=edaba06c0d190d8029ae1eed039f3c6c4cdc60ced3fe2e88788659294c31c23c
ADD https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-$MEDIASDK_VERSION.tar.gz /tmp/mediasdk.tar.gz

ARG FFMPEG_VERSION=5.1.2-4
ARG FFMPEG_SHA256=2fe158d5e568d06af093b19c7f11258e1ba5335eada3adfbf6a2035463f8c944
ADD https://github.com/jellyfin/jellyfin-ffmpeg/archive/refs/tags/v$FFMPEG_VERSION.tar.gz /tmp/ffmpeg.tar.gz

ARG LD_LIBRARY_PATH=/opt/intel/mediasdk/lib:/usr/local/lib:/usr/lib:/lib
ARG PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/lib/pkgconfig
ARG SRC=/usr/local
ARG PREFIX=/usr/local

RUN set -ex; \
    apk add --no-cache --upgrade \
        autoconf \
        automake \
        alpine-sdk \
        bash \
        ca-certificates \
        cmake \
        coreutils \
        cunit-dev \
        curl \
        dos2unix \
        g++ \
        gcc \
        libtool \
        musl \
        nasm \
        python3 \
        tzdata \
        unzip \
        yasm \
        \
        cunit-dev \
        dav1d-dev \
        fdk-aac-dev \
        ffmpeg-libs \
        ffmpeg-dev \
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
        intel-media-driver-dev \
        libva-dev \
        libva-intel-driver;

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

WORKDIR /tmp/ffmpeg

RUN set -ex; \
    echo "$FFMPEG_SHA256  ../ffmpeg.tar.gz" | sha256sum --status -c -; \
    tar xf ../ffmpeg.tar.gz --strip-components=1; \
    cat debian/patches/*.patch | patch -p1; \
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
    /tmp/build/extractlibrary cplist /build; \
    cp --archive --parents --no-dereference /opt/intel /build; \
    rm -rf extractlibrary cplist

FROM misotolar/jellyfin-server:f39818a1

LABEL mantainer="michal@sotolar.com"

ENV LD_LIBRARY_PATH=/opt/intel/mediasdk/lib:/usr/local/lib:/usr/lib:/lib

RUN set -ex; \
    apk add --no-cache --upgrade \
        libva-intel-driver \
        intel-media-driver \
    ; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY --from=build /build /

ENTRYPOINT /usr/lib/jellyfin/jellyfin --ffmpeg /usr/local/bin/ffmpeg
