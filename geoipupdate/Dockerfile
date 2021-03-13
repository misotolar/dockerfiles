FROM alpine:3.13

LABEL maintainer="michal@sotolar.com"

ARG VERSION=4.6.0
ARG SHA256=b6f6c5886586ea869fafed34e42b33d45e361770451fbf81bf2bc0694f679508
ARG URL=https://github.com/maxmind/geoipupdate/releases/download/v${VERSION}/geoipupdate_${VERSION}_linux_amd64.tar.gz

ENV GEOIPUPDATE_ACCOUNT_ID 0
ENV GEOIPUPDATE_LICENSE_KEY 000000000000
ENV GEOIPUPDATE_EDITION_IDS "GeoLite2-Country GeoLite2-City"
ENV GEOIPUPDATE_SCHEDULE "0 9 * * 4"
ENV GEOIPUPDATE_DB_DIR /usr/share/GeoIP
ENV GEOIPUPDATE_HOST updates.maxmind.com

RUN set -ex; \
    apk add --no-cache --upgrade \
        ca-certificates \
        libintl; \
    apk add --no-cache --virtual .build-deps \
        curl \
        gettext; \
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
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY GeoIP.conf /etc/GeoIP.conf.docker
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /usr/share/GeoIP

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["crond", "-f"]