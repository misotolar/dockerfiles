ARG DOTNET_VERSION=3.1
ARG ALPINE_VERSION=3.13

FROM mcr.microsoft.com/dotnet/core/sdk:${DOTNET_VERSION}-alpine AS build

ARG VERSION=10.6.4

WORKDIR /build

RUN set -ex; \
    apk add --no-cache git; \
    git clone --branch v${VERSION} --depth=1 -c advice.detachedHead=false https://github.com/jellyfin/jellyfin /build; \
    dotnet publish \
        --configuration Release \
        --output=/build/dist \
        --self-contained \
        --runtime alpine-x64 \
        "-p:GenerateDocumentationFile=false;DebugSymbols=false;DebugType=none" \
        Jellyfin.Server

FROM node:current-alpine AS build_web

ARG VERSION=10.6.4

WORKDIR /build

RUN set -ex; \
    apk add --no-cache \
        alpine-sdk \
        autoconf \
        automake \
        curl \
        g++ \
        gcc \
        gifsicle \
        git \
        libtool \
        make \
        musl-dev \
        nasm \
        python2 \
        zlib \
        zlib-dev; \
        git clone --branch v${VERSION} --depth=1 -c advice.detachedHead=false https://github.com/jellyfin/jellyfin-web /build; \
        yarn install;

FROM alpine:${ALPINE_VERSION} as build_ffmpeg

ARG FFMPEG_VERSION=4.3.1
ARG FFMPEG_URL="https://ffmpeg.org/releases/ffmpeg-$FFMPEG_VERSION.tar.bz2"
ARG FFMPEG_SHA256=f4a4ac63946b6eee3bbdde523e298fca6019d048d6e1db0d1439a62cea65f0d9

ARG LIBMFX_VERSION=20.5.1
ARG LIBMFX_URL="https://github.com/Intel-Media-SDK/MediaSDK/archive/intel-mediasdk-$LIBMFX_VERSION.tar.gz"
ARG LIBMFX_SHA256=047986646f185313df2159fd44bccd870e173bb1cae9c2501ac6b9774bfd424b

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
        libva-dev \
        libva-intel-driver \
        libvdpau-dev \
        mesa-va-gallium \
        mesa-vdpau-gallium; \
    echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    echo http://dl-2.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories; \
    apk add --no-cache \
        intel-media-driver-dev \
        libva-vdpau-driver; \
    echo http://dl-2.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories; \
    apk add --no-cache \
        gcc \
        musl;

WORKDIR /tmp/libmfx

RUN set -ex; \
    curl -fsSL -o libmfx.tar.gz $LIBMFX_URL; \
    echo "$LIBMFX_SHA256  libmfx.tar.gz" | sha256sum --status -c -; \
    tar xf libmfx.tar.gz --strip-components=1; \
    mkdir build; \
    cd build; \
    cmake -DCMAKE_BUILD_TYPE=MinSizeRel ../; \
    make -j $(nproc) && \
    make -j $(nproc) install

ENV CFLAGS="-O2 -pipe -march=x86-64 -mtune=generic"
ENV CXXFLAGS="-O2 -pipe -march=x86-64 -mtune=generic"

WORKDIR /tmp/ffmpeg

RUN set -ex; \
    curl -fsSL -o ffmpeg.tar.bz2 $FFMPEG_URL; \
    echo "$FFMPEG_SHA256  ffmpeg.tar.bz2" | sha256sum --status -c -; \
    tar xf ffmpeg.tar.bz2 --strip-components=1; \
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
        --extra-cflags="-I${PREFIX}/include ${CFLAGS}" \
        --extra-cxxflags="-I${PREFIX}/include ${CXXFLAGS}" \
        --extra-ldflags="-L${PREFIX}/lib" \
        --extra-libs="-lpthread -lm" \
        --prefix="${PREFIX}" \
        \
        --enable-libmfx \
        --enable-vaapi \
        --enable-vdpau \
        || (cat ffbuild/config.log ; false); \
    mkdir -p /build${PREFIX}/bin/; \
    make -j$(nproc) install tools/qt-faststart; \
    cp tools/qt-faststart /build${PREFIX}/bin

WORKDIR /tmp/build

RUN set -ex; \
    curl -fsSL -o extractlibrary https://raw.githubusercontent.com/collelog/ffmpeg/master/DockerTools/extractlibrary; \
    chmod 755 extractlibrary; \
    echo /usr/local/bin/ffmpeg >> cplist; \
    echo /usr/local/bin/ffprobe >> cplist; \
    ./extractlibrary cplist /build; \
    cp --archive --parents --no-dereference /opt/intel /build

FROM alpine:${ALPINE_VERSION}

LABEL mantainer="michal@sotolar.com"

ENV JELLYFIN_CONFIG_DIR=/config/config
ENV JELLYFIN_DATA_DIR=/config/data
ENV JELLYFIN_LOG_DIR=/config/log
ENV JELLYFIN_CACHE_DIR=/config/cache
ENV JELLYFIN_WEB_DIR=/usr/share/jellyfin-web
ENV JELLYFIN_FFMPEG_PATH=/usr/local/bin/ffmpeg

ENV LD_LIBRARY_PATH=/opt/intel/mediasdk/lib64:/usr/local/lib64:/usr/local/lib:/usr/lib:/lib
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

RUN set -ex; \
    apk add --no-cache --upgrade \
        fontconfig \
        gcompat \
        icu-libs \
        libssl1.1 \
        libstdc++ \
        libintl \
        \
        libva-intel-driver \
        mesa-va-gallium \
        mesa-vdpau-gallium; \
    echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    echo http://dl-2.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories; \
    apk add --no-cache --upgrade \
        intel-media-driver \
        libva-vdpau-driver;

COPY --from=build /build/dist /usr/lib/jellyfin
COPY --from=build_web /build/dist /usr/share/jellyfin-web
COPY --from=build_ffmpeg /build /

EXPOSE 8096 8920 7359/udp 1900/udp
VOLUME /config /media

ENTRYPOINT /usr/lib/jellyfin/jellyfin --ffmpeg ${JELLYFIN_FFMPEG_PATH}
