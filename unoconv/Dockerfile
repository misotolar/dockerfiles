FROM ubuntu:bionic

LABEL maintainer="michal@sotolar.com"

ARG URL=https://raw.githubusercontent.com/unoconv/unoconv/master/unoconv

RUN set -ex; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" | tee /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        libreoffice-common \
        libreoffice-writer \
        tzdata \
        unoconv; \
    ln -fs /usr/bin/python3 /usr/local/bin/python; \
    curl -fsSL -o /usr/local/bin/unoconv ${URL}; \
    chmod 755 /usr/local/bin/unoconv; \
    apt-get remove --purge -y \
        ca-certificates \
        curl; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["unoconv", "--listener"]
