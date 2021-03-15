FROM php:7.4-fpm-alpine

LABEL maintainer="michal@sotolar.com"

ARG RELEASE=7-13-0
ARG SHA256=8694707ebff7bf4357b2920dacf12344e2c6d62c8143dc0f65794f50756c90fd
ARG URL=https://github.com/phppgadmin/phppgadmin/archive/REL_$RELEASE.tar.gz

ENV MAX_EXECUTION_TIME 600
ENV MEMORY_LIMIT 512M
ENV UPLOAD_LIMIT 2048K

RUN set -ex; \
    apk add --no-cache \
        bash \
        postgresql-client \
        rsync \
        tzdata; \
    apk add --no-cache --virtual .build-deps \
        postgresql-dev \
    ; \
    docker-php-ext-install \
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
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
    } > $PHP_INI_DIR/conf.d/opcache-recommended.ini; \
    \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'allow_url_fopen=Off'; \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'max_input_vars=10000'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/phpmyadmin-misc.ini; \
    curl -fsSL -o phpPgAdmin.tar.gz $URL; \
    echo "$SHA256  phpPgAdmin.tar.gz" | sha256sum -c -; \
    mkdir -p /usr/src/phppgadmin; \
    tar -xf phpPgAdmin.tar.gz -C /usr/src/phppgadmin --strip-components=1; \
    rm -rf \
        phpPgAdmin.tar.gz \
        /usr/src/phppgadmin/BUGS \
        /usr/src/phppgadmin/DEVELOPERS \
        /usr/src/phppgadmin/FAQ \
        /usr/src/phppgadmin/HISTORY \
        /usr/src/phppgadmin/INSTALL \
        /usr/src/phppgadmin/TODO \
        /usr/src/phppgadmin/TRANSLATORS \
        /usr/src/phppgadmin/composer.json \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY config.inc.php /etc/phppgadmin/config.inc.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /var/www/html

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
