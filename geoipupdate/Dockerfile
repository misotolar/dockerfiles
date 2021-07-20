FROM alpine:3.13

LABEL maintainer="michal@sotolar.com"

ARG VERSION=4.8.0
ARG SHA256=c9d3c8f80e955125c4ee208b0cb0c219342ee602a7e55c3a5dfd63c5a32b1062
ARG URL=https://github.com/maxmind/geoipupdate/releases/download/v${VERSION}/geoipupdate_${VERSION}_linux_amd64.tar.gz

ENV GEOIPUPDATE_ACCOUNT_ID 0
ENV GEOIPUPDATE_LICENSE_KEY 000000000000
ENV GEOIPUPDATE_EDITION_IDS "GeoLite2-Country GeoLite2-City"
ENV GEOIPUPDATE_SCHEDULE "0 9 * * 4"
ENV GEOIPUPDATE_XTABLES_SCHEDULE "5 9 * * 4"
ENV GEOIPUPDATE_DB_DIR /usr/share/GeoIP
ENV GEOIPUPDATE_HOST updates.maxmind.com

RUN set -ex; \
    apk add --no-cache --upgrade \
        ca-certificates \
        curl \
        libintl \
        perl \
        unzip; \
    apk add --no-cache --virtual .build-deps \
        curl \
        gettext \
        make \
        g++ \
        musl-dev \
        perl-dev \
        wget; \
    curl -fsSL -o /tmp/cpanm http://xrl.us/cpanm; \
    chmod 755 /tmp/cpanm; \
    /tmp/cpanm -v Text::CSV_XS; \
    /tmp/cpanm Net::CIDR::Lite; \
    curl -fsSL -o geoipupdate.tar.gz $URL; \
    echo "$SHA256  geoipupdate.tar.gz" | sha256sum -c -; \
    tar --extract \
        --file=geoipupdate.tar.gz \
        --directory=/usr/local/bin \
        --strip-components=1 \
        geoipupdate_${VERSION}_linux_amd64/geoipupdate; \
    cp /usr/bin/envsubst /usr/local/bin/envsubst; \
    apk del --no-network .build-deps; \
    rm -rf \
        geoipupdate.tar.gz \
        /root/.cpanm \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY GeoIP.conf /etc/GeoIP.conf.docker
COPY xtables/xt-build.pl /usr/local/bin/xt-build.pl
COPY xtables/xt-update.sh /usr/local/bin/xt-update.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /usr/share/GeoIP /usr/share/xt_geoip

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["crond", "-f"]