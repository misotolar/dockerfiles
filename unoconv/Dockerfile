FROM debian:buster-slim

LABEL maintainer="michal@sotolar.com"

ARG URL=https://raw.githubusercontent.com/unoconv/unoconv/master/unoconv

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN set -ex; \
    echo "deb http://deb.debian.org/debian buster main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        tzdata; \
    apt-get install -t buster-backports --no-install-recommends -y \
        libreoffice-calc-nogui \
        libreoffice-core-nogui \
        libreoffice-writer-nogui \
        python3-uno; \
    ln -fs /usr/bin/python3 /usr/local/bin/python; \
    curl -fsSL -o /usr/local/bin/unoconv ${URL}; \
    chmod 755 /usr/local/bin/unoconv; \
    apt-get remove --purge -y \
        ca-certificates \
        curl; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /usr/lib/libreoffice/share/config/* \
        /usr/lib/libreoffice/share/gallery/* \
        /usr/share/libreoffice/share/config/* \
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
CMD ["unoconv", "--listener"]
