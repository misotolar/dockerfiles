FROM alpine:3.17

LABEL mantainer="michal@sotolar.com"

ARG VERSION=1.0.1
ARG SHA256=1a0254a039ec0b415e45ea8cf08ec99b574cc1a2a3253afe6cde3dc360a94395
ADD https://github.com/LMBernardo/mjpg-streamer/archive/refs/tags/v${VERSION}.tar.gz /tmp/mjpg-streamer.tar.gz

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
        jpeg-dev \
        linux-headers \
        v4l-utils-dev \
    ; \
    echo "$SHA256 */tmp/mjpg-streamer.tar.gz" | sha256sum -c -; \
    tar xf /tmp/mjpg-streamer.tar.gz --strip-components=1; \
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