FROM php:7.4-fpm-alpine3.14

LABEL maintainer="michal@sotolar.com"

ARG VERSION=7-13-0
ARG SHA256=8694707ebff7bf4357b2920dacf12344e2c6d62c8143dc0f65794f50756c90fd
ADD https://github.com/phppgadmin/phppgadmin/archive/REL_${VERSION}.tar.gz /usr/src/phpPgAdmin.tar.gz

ENV PHP_MAX_EXECUTION_TIME 600
ENV PHP_UPLOAD_LIMIT 2048K
ENV PHP_MEMORY_LIMIT 512M

WORKDIR /usr/local/phppgadmin

RUN set -ex; \
    apk add --no-cache \
        postgresql-client \
    ; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        postgresql-dev \
    ; \
    docker-php-ext-install \
        opcache \
        pgsql \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .phppgadmin-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'expose_php=off'; \
        echo 'allow_url_fopen=off'; \
        echo 'max_execution_time=${PHP_MAX_EXECUTION_TIME}'; \
        echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
        echo 'post_max_size=${PHP_UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${PHP_UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/phppgadmin-misc.ini; \
    echo "$SHA256 */usr/src/phpPgAdmin.tar.gz" | sha256sum -c -; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY config.inc.php /usr/local/etc/phppgadmin/config.inc.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY exclude.txt /usr/src/phpPgAdmin.exclude

VOLUME /usr/local/phppgadmin

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
