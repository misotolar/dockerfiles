FROM debian:bullseye-slim

LABEL maintainer="michal@sotolar.com"

ARG URL=https://raw.githubusercontent.com/unoconv/unoconv/0.9.0/unoconv
ARG SHA256=f5c33a280c3050025322935687bb0b7453dc1c205c0bbe2318ff55c735b007c0

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /usr/local/bin

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        libreoffice-calc-nogui \
        libreoffice-writer-nogui \
        python3-uno; \
    curl -fsSL -o /usr/local/bin/unoconv ${URL}; \
    echo "$SHA256 */usr/local/bin/unoconv" | sha256sum -c -; \
    chmod 755 /usr/local/bin/unoconv; \
    ln -fs /usr/bin/python3 /usr/local/bin/python; \
    apt-get remove --purge -y \
        ca-certificates \
        curl; \
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
CMD ["unoconv", "--listener"]
