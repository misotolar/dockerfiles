FROM alpine:3.17

LABEL mantainer="michal@sotolar.com"

ARG VERSION=310b29f4a94c46652b20c4b7b6e5cf24e532af39
ARG URL=https://github.com/jacksonliam/mjpg-streamer.git

WORKDIR /tmp/build

RUN set -ex; \
    apk add --no-cache \
        v4l-utils-libs \
        jpeg \
    ; \
    apk add --no-cache --virtual .build-deps \
        cmake \
        make \
        musl-dev \
        gcc \
        git \
        jpeg-dev \
        linux-headers \
        v4l-utils-dev \
    ; \
    git clone ${URL} --depth=1 .; \
    git reset --hard ${VERSION}; \
    cd mjpg-streamer-experimental; \
    make USE_LIBV4L2=true all; \
    make install; \
    apk del --no-network .build-deps; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

STOPSIGNAL SIGKILL
CMD ["tail", "-f", "/dev/null"]