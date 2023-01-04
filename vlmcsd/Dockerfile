FROM alpine:3.17 as build

ARG VERSION=65228e5c7916acd947ffb53be18abadafbc1be56
ARG SHA256=804ec9e43e2d264247ab4d10e3e141b267bbb5b26e6adcd7354957d926c12df4
ADD https://github.com/Wind4/vlmcsd/archive/$VERSION.tar.gz /tmp/vlmcsd.tar.gz

WORKDIR /build

RUN set -ex; \
    apk add --no-cache --upgrade \
        build-base \
        make \
    ; \
    echo "$SHA256  /tmp/vlmcsd.tar.gz" | sha256sum -c -; \
    tar xf /tmp/vlmcsd.tar.gz --strip-components=1; \
    make; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

FROM alpine:3.17

WORKDIR /usr/local/vlmcsd

RUN set -ex; \
    apk add --no-cache --upgrade \
        tzdata \
    ; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY --from=build /build/bin/vlmcsd /usr/local/vlmcsd/vlmcsd
COPY --from=build /build/etc/vlmcsd.kmd /usr/local/vlmcsd/vlmcsd.kmd

EXPOSE 1688/tcp

ENTRYPOINT /usr/local/vlmcsd/vlmcsd -D -d -t 3 -e -v
