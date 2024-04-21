FROM alpine:3.19.1

LABEL maintainer="michal@sotolar.com"

COPY entrypoint-hooks.sh /usr/local/bin/entrypoint-hooks.sh
COPY entrypoint-hooks.sh /usr/local/bin/entrypoint-post-hooks.sh

RUN set -ex; \
    mkdir -p /usr/local/bin/entrypoint-hooks.d; \
    mkdir -p /usr/local/bin/entrypoint-post-hooks.d
