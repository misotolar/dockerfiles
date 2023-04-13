FROM alpine:3.17

LABEL maintainer="michal@sotolar.com"

ARG VERSION=5.0.2
ARG SHA256=f0f0ba08d2a884dfaf239adfeb08519c44693db56863aa582dcd2dc9913b0e81
ADD https://github.com/maxmind/geoipupdate/releases/download/v${VERSION}/geoipupdate_${VERSION}_linux_amd64.tar.gz /tmp/geoipupdate.tar.gz

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
        perl-net-cidr-lite \
        perl-text-csv_xs \
        unzip \
    ; \
    apk add --no-cache --virtual .build-deps \
        gettext \
    ; \
    echo "$SHA256  /tmp/geoipupdate.tar.gz" | sha256sum -c -; \
    tar --extract \
        --file=/tmp/geoipupdate.tar.gz \
        --directory=/usr/local/bin \
        --strip-components=1 \
        geoipupdate_${VERSION}_linux_amd64/geoipupdate; \
    cp /usr/bin/envsubst /usr/local/bin/envsubst; \
    apk del --no-network .build-deps; \
    rm -rf \
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
