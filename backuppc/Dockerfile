FROM alpine:3.19

LABEL mantainer="michal@sotolar.com"

ARG VERSION=4.4.0
ARG SHA256=8bc04cd513d47629508bd2fd6f455ced38316974913638e971f44e37786c6365
ADD https://github.com/backuppc/backuppc/releases/download/$VERSION/BackupPC-$VERSION.tar.gz /usr/src/backuppc.tar.gz

ARG XS_VERSION=0.62
ARG XS_SHA256=94d863083a466558f82f10b1b95db7742ea99ebce808214f20897b343dc32b18
ADD https://github.com/backuppc/backuppc-xs/releases/download/$XS_VERSION/BackupPC-XS-$XS_VERSION.tar.gz /tmp/backuppc-xs.tar.gz

ARG RSYNC_VERSION=3.1.3.0
ARG RSYNC_SHA256=3eeb137319b608512b2d23c54ea8b52b511db806ffbd5fa730a394431d556f3f
ADD https://github.com/backuppc/rsync-bpc/releases/download/$RSYNC_VERSION/rsync-bpc-$RSYNC_VERSION.tar.gz /tmp/rsync-bpc.tar.gz

ENV BACKUPPC_UUID=1000
ENV BACKUPPC_GUID=1000
ENV BACKUPPC_FCGI=/var/run/fcgiwrap/fcgiwrap.sock

RUN set -ex; \
    apk add --no-cache \
        apache2-utils \
        bash \
        ca-certificates \
        expat \
        fcgiwrap \
        gzip \
        iputils \
        libstdc++ \
        libgomp \
        msmtp \
        openssh \
        par2cmdline \
        patch \
        perl \
        perl-archive-zip \
        perl-cgi \
        perl-file-listing \
        perl-json-xs \
        perl-xml-rss \
        pigz \
        rrdtool \
        rsync \
        runit \
        samba-client \
        shadow \
        spawn-fcgi \
        supervisor \
        tar \ 
        ttf-dejavu \
    ; \
    apk add --no-cache --virtual .build-deps \
        acl-dev \
        autoconf \
        automake \
        gcc \
        g++ \
        make \
        perl-dev \
    ; \
    mkdir -p /home/backuppc; \
    rm -rf /usr/sbin/sendmail; \
    ln -s /usr/bin/msmtp /usr/sbin/sendmail; \
    sed -i -e 's/^# Host \*/Host */g' /etc/ssh/ssh_config; \
    sed -i -e 's/^#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config; \
    echo "$SHA256 */usr/src/backuppc.tar.gz" | sha256sum -c -; \
    mkdir -p /build/backuppc-xs && cd /build/backuppc-xs; \
    echo "$XS_SHA256 */tmp/backuppc-xs.tar.gz" | sha256sum -c -; \
    tar xf /tmp/backuppc-xs.tar.gz --strip-components=1; \
    perl Makefile.PL; \
    make; \
    make test; \
    make install; \
    mkdir -p /build/rsync-bpc && cd /build/rsync-bpc; \
    echo "$RSYNC_SHA256 */tmp/rsync-bpc.tar.gz" | sha256sum -c -; \
    tar xf /tmp/rsync-bpc.tar.gz --strip-components=1; \
    ./configure; \
    make reconfigure; \
    make; \
    make install; \
    apk del --no-network .build-deps; \
    rm -rf \
        /build/* \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

WORKDIR /home/backuppc

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY patch/2c9270b9b849b2c86ae6301dd722c97757bc9256.patch /usr/src/2c9270b9b849b2c86ae6301dd722c97757bc9256.patch
COPY service /etc/service

VOLUME /etc/backuppc /home/backuppc /data/backuppc

ENTRYPOINT ["entrypoint.sh"]
CMD ["runsvdir", "-P", "/etc/service"]
