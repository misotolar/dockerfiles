FROM debian:bullseye-slim

LABEL maintainer="michal@sotolar.com"

ARG VERSION=2d0a3a815e07094aca5ed094fd3825fbe6f0819d
ARG SHA256=6855c633dcb99246115aa2bfee46921c839a1ab37395bad4ef3d72be8f4f9041
ADD https://github.com/unoconv/unoconv/archive/$VERSION.tar.gz /tmp/unoconv.tar.gz

ARG LIBREOFFICE_VERSION=4:7.4.5-1~bpo11+1

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /usr/local/bin

RUN set -ex; \
    echo "deb http://deb.debian.org/debian bullseye main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install -t bullseye-backports --no-install-recommends -y \
        libreoffice-calc-nogui=$LIBREOFFICE_VERSION \
        libreoffice-writer-nogui=$LIBREOFFICE_VERSION \
        python3-uno=$LIBREOFFICE_VERSION \
    ; \
    echo "$SHA256 */tmp/unoconv.tar.gz" | sha256sum -c -; \
    tar xf /tmp/unoconv.tar.gz --strip-components=1 -C /usr/local/bin unoconv-$VERSION/unoconv; \
    ln -fs /usr/bin/python3 /usr/local/bin/python; \
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
