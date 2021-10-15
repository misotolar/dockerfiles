FROM debian:bullseye-slim

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.1

ENV INTERFACE=127.0.0.1
ENV PORT=2002

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        libreoffice-calc-nogui \
        libreoffice-writer-nogui \
        python3-pip \
        python3-uno; \
    pip install unoserver==$VERSION; \
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

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD unoserver --interface $INTERFACE --port $PORT

