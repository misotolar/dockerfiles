FROM ubuntu:bionic

LABEL maintainer="michal@sotolar.com"

ENV OPENCV_VERSION 2.4.13.6
ENV OPENCV_SHA256 6ecbeea11f68356b748e35f758f4406067d3a2f6339e4582c63373fa6c3f5a72
ENV OPENCV_URL https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz

ENV LEPTONICA_VERSION 1.80.0
ENV LEPTONICA_SHA256 ec9c46c2aefbb960fb6a6b7f800fe39de48343437b6ce08e30a8d9688ed14ba4
ENV LEPTONICA_URL https://github.com/DanBloomberg/leptonica/releases/download/${LEPTONICA_VERSION}/leptonica-${LEPTONICA_VERSION}.tar.gz

ENV TESSERACT_VERSION 3.05.02
ENV TESSERACT_SHA256 494d64ffa7069498a97b909a0e65a35a213989e0184f1ea15332933a90d43445
ENV TESSERACT_URL https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz

ENV OPENALPR_VERSION 6ead2fb8f72ac1929a2e04912c5795af0bf37761
ENV OPENALPR_URL https://github.com/openalpr/openalpr.git

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

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
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        libcurl4 \
        libcurl4-openssl-dev \
        libjpeg-turbo8 \
        libjpeg8 \
        libjpeg8-dev \
        liblog4cplus-1.1-9 \
        liblog4cplus-dev \
        libtool \
        pkg-config \
        tzdata; \
    mkdir -p /build/opencv; \
    curl -fsSL -o /build/opencv.tar.gz $OPENCV_URL; \
    echo "$OPENCV_SHA256  /build/opencv.tar.gz" | sha256sum --status -c -; \
    tar xf /build/opencv.tar.gz -C /build/opencv --strip-components=1; \
    mkdir -p /build/opencv/release; \
    cd /build/opencv/release; \
    cmake \
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
        ..; \
    make; \
    make install; \
    mkdir -p /build/leptonica; \
    curl -fsSL -o /build/leptonica.tar.gz $LEPTONICA_URL; \
    echo "$LEPTONICA_SHA256  /build/leptonica.tar.gz" | sha256sum --status -c -; \
    tar xf /build/leptonica.tar.gz -C /build/leptonica --strip-components=1; \
    cd /build/leptonica; \
    autoreconf -ivf; \
    ./configure; \
    make -j$(nproc); \
    make install; \
    mkdir -p /build/tesseract; \
    curl -fsSL -o /build/tesseract.tar.gz $TESSERACT_URL; \
    echo "$TESSERACT_SHA256  /build/tesseract.tar.gz" | sha256sum --status -c -; \
    tar xf /build/tesseract.tar.gz -C /build/tesseract --strip-components=1; \
    cd /build/tesseract; \
    ./autogen.sh; \
    ./configure LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include"; \
    make -j$(nproc); \
    make install; \
    ldconfig; \
    git clone $OPENALPR_URL /build/openalpr; \
    cd /build/openalpr; \
    git reset --hard $OPENALPR_VERSION; \
    mkdir -p /build/openalpr/src/build; \
    cd /build/openalpr/src/build; \
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
        libcurl4-openssl-dev \
        libjpeg8-dev \
        liblog4cplus-dev \
        libtool \
        pkg-config; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /build \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# https://github.com/openalpr/openalpr/pull/869
COPY runtime/eu.patterns /usr/share/openalpr/runtime_data/postprocess/eu.patterns

STOPSIGNAL SIGKILL
CMD ["tail", "-f", "/dev/null"]