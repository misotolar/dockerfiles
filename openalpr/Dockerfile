FROM ubuntu:jammy

LABEL maintainer="michal@sotolar.com"

ARG VERSION=736ab0e608cf9b20d92f36a873bb1152240daa98
ARG SHA256=2157aef52e5782cbb4117669f3ffdc125281f71c773b61d50f2133a2a3cb66fe
ADD https://github.com/openalpr/openalpr/archive/$VERSION.tar.gz /tmp/openalpr.tar.gz 

ARG OPENCV_VERSION=4.7.0
ARG OPENCV_SHA256=8df0079cdbe179748a18d44731af62a245a45ebf5085223dc03133954c662973
ADD https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz /tmp/opencv.tar.gz

ARG LEPTONICA_VERSION=1.82.0
ARG LEPTONICA_SHA256=155302ee914668c27b6fe3ca9ff2da63b245f6d62f3061c8f27563774b8ae2d6
ADD https://github.com/DanBloomberg/leptonica/releases/download/$LEPTONICA_VERSION/leptonica-$LEPTONICA_VERSION.tar.gz /tmp/leptonica.tar.gz

ARG TESSERACT_VERSION=4.1.3
ARG TESSERACT_SHA256=83dc56b544be938983f528c777e4e1d906205b0f6dc0110afc223f2cc1cec6d3
ADD https://github.com/tesseract-ocr/tesseract/archive/$TESSERACT_VERSION.tar.gz /tmp/tesseract.tar.gz

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ENV BEANSTALKD_LISTEN_ADDR 127.0.0.1
ENV BEANSTALKD_LISTEN_PORT 11300

RUN set -ex; \
    echo "deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse" | tee /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        autotools-dev \
        beanstalkd \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        libavcodec58 \
        libavcodec-dev \
        libavformat58 \
        libavformat-dev \
        libcurl4 \
        libcurl4-openssl-dev \
        libjpeg8 \
        libjpeg8-dev \
        liblog4cplus-2.0.5 \
        liblog4cplus-dev \
        libswscale5 \
        libswscale-dev \
        libtiff5 \
        libtiff5-dev \
        libtool \
        pkg-config \
        tzdata \
    ; \
    mkdir -p /tmp/opencv; \
    echo "$OPENCV_SHA256  /tmp/opencv.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/opencv.tar.gz -C /tmp/opencv --strip-components=1; \
    mkdir -p /tmp/opencv/release; \
    cd /tmp/opencv/release; \
    cmake \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_apps=OFF \
        -DBUILD_DOCS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DBUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr/local/ \
        -DWITH_PNG=OFF \
        -DWITH_TIFF=OFF \
        -DWITH_WEBP=OFF \
        -DWITH_OPENJPEG=OFF \
        -DWITH_JASPER=OFF \
        -DWITH_OPENEXR=OFF \
        -DWITH_IPP=OFF \
        .. \
    ; \
    make -j$(nproc); \
    make install; \
    \
    mkdir -p /tmp/leptonica; \
    echo "$LEPTONICA_SHA256  /tmp/leptonica.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/leptonica.tar.gz -C /tmp/leptonica --strip-components=1; \
    cd /tmp/leptonica; \
    autoreconf -ivf; \
    ./configure; \
    make -j$(nproc); \
    make install; \
    \
    mkdir -p /tmp/tesseract; \
    echo "$TESSERACT_SHA256  /tmp/tesseract.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/tesseract.tar.gz -C /tmp/tesseract --strip-components=1; \
    cd /tmp/tesseract; \
    ./autogen.sh; \
    ./configure LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include"; \
    make -j$(nproc); \
    make install; \
    ldconfig; \
    \
    mkdir -p /tmp/openalpr; \
    echo "$SHA256  /tmp/openalpr.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/openalpr.tar.gz -C /tmp/openalpr --strip-components=1; \
    mkdir -p /tmp/openalpr/src/build; \
    cd /tmp/openalpr/src/build; \
    cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
        ..; \
    make -j$(nproc); \
    make install; \
    apt-get remove --purge -y \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        dpkg-dev \
        git \
        libavcodec-dev \
        libavformat-dev \
        libavresample-dev \
        libcurl4-openssl-dev \
        libjpeg8-dev \
        liblog4cplus-dev \
        libswscale-dev \
        libtiff5-dev \
        libtool \
        pkg-config; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /usr/share/doc/* \
        /usr/share/icons/* \
        /usr/share/man/* \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# https://github.com/openalpr/openalpr/pull/869
# https://github.com/openalpr/openalpr/pull/966
COPY runtime/eu.patterns /usr/share/openalpr/runtime_data/postprocess/eu.patterns
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
