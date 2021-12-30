FROM alpine:3.15

LABEL maintainer="michal@sotolar.com"

RUN set -ex; \
    apk add --no-cache --update \
        curl \
        jq \
    ; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;
