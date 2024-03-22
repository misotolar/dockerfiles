FROM alpine:3.19

LABEL maintainer="michal@sotolar.com"

ARG UNOSERVER_VERSION=2.0.1

ENV INTERFACE=127.0.0.1
ENV PORT=2003
ENV UNO_INTERFACE=127.0.0.1
ENV UNO_PORT=2002

RUN set -ex; \
    apk add --no-cache \
        fontconfig \
        libreoffice-calc \
        libreoffice-writer \
    ; \
    apk add --no-cache --virtual .build-deps \
        py3-pip \
    ; \
    pip install --break-system-packages -U unoserver==$UNOSERVER_VERSION; \
    apk del --no-network .build-deps; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY javasettings.xml /usr/lib/libreoffice/share/config/javasettings_Linux_X86_64.xml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD unoserver --interface $INTERFACE --uno-interface $UNO_INTERFACE --port $PORT --uno-port $UNO_PORT