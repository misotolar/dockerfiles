FROM debian:bookworm-slim

LABEL maintainer="michal@sotolar.com"

ARG UNOSERVER_VERSION=2.0.1
ARG LIBREOFFICE_VERSION=4:7.4.7-1+deb12u1

ENV INTERFACE=127.0.0.1
ENV PORT=2003
ENV UNO_INTERFACE=127.0.0.1
ENV UNO_PORT=2002

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN set -ex; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        libreoffice-calc-nogui=$LIBREOFFICE_VERSION \
        libreoffice-writer-nogui=$LIBREOFFICE_VERSION \
        python3-uno=$LIBREOFFICE_VERSION \
        python3-pip; \
    pip install unoserver==$UNOSERVER_VERSION --break-system-packages; \
    apt-get remove --purge -y \
        python3-pip; \
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

COPY javasettings.xml /usr/lib/libreoffice/share/config/javasettings_Linux_X86_64.xml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD unoserver --interface $INTERFACE --uno-interface $UNO_INTERFACE --port $PORT --uno-port $UNO_PORT

