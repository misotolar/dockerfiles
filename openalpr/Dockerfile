FROM ubuntu:bionic

LABEL maintainer="michal@sotolar.com"

ARG VERSION=6ead2fb8f72ac1929a2e04912c5795af0bf37761
ARG SHA256=0a2a39bc22704d10cf935a59129d8cfc281d3c71781e54d6b9f37d22fdc1c061
ADD https://github.com/openalpr/openalpr/archive/$VERSION.tar.gz /tmp/openalpr.tar.gz 

ARG OPENCV_VERSION=2.4.13.6
ARG OPENCV_SHA256=6ecbeea11f68356b748e35f758f4406067d3a2f6339e4582c63373fa6c3f5a72
ADD https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz /tmp/opencv.tar.gz

ARG LEPTONICA_VERSION=1.80.0
ARG LEPTONICA_SHA256=ec9c46c2aefbb960fb6a6b7f800fe39de48343437b6ce08e30a8d9688ed14ba4
ADD https://github.com/DanBloomberg/leptonica/releases/download/$LEPTONICA_VERSION/leptonica-$LEPTONICA_VERSION.tar.gz /tmp/leptonica.tar.gz

ARG TESSERACT_VERSION=3.05.02
ARG TESSERACT_SHA256=494d64ffa7069498a97b909a0e65a35a213989e0184f1ea15332933a90d43445
ADD https://github.com/tesseract-ocr/tesseract/archive/$TESSERACT_VERSION.tar.gz /tmp/tesseract.tar.gz

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ENV BEANSTALKD_LISTEN_ADDR 127.0.0.1
ENV BEANSTALKD_LISTEN_PORT 11300

RUN set -ex; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" | tee /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list; \
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
        git \
        libavcodec57 \
        libavcodec-dev \
        libavformat57 \
        libavformat-dev \
        libavresample3 \
        libavresample-dev \
        libcurl4 \
        libcurl4-openssl-dev \
        libjpeg8 \
        libjpeg8-dev \
        liblog4cplus-1.1-9 \
        liblog4cplus-dev \
        libswscale4 \
        libswscale-dev \
        libtool \
        pkg-config \
        tzdata; \
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
    make; \
    make install; \
    mkdir -p /tmp/leptonica; \
    echo "$LEPTONICA_SHA256  /tmp/leptonica.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/leptonica.tar.gz -C /tmp/leptonica --strip-components=1; \
    cd /tmp/leptonica; \
    autoreconf -ivf; \
    ./configure; \
    make -j$(nproc); \
    make install; \
    mkdir -p /tmp/tesseract; \
    echo "$TESSERACT_SHA256  /tmp/tesseract.tar.gz" | sha256sum --status -c -; \
    tar xf /tmp/tesseract.tar.gz -C /tmp/tesseract --strip-components=1; \
    cd /tmp/tesseract; \
    ./autogen.sh; \
    ./configure LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include"; \
    make -j$(nproc); \
    make install; \
    ldconfig; \
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
