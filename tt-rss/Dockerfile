FROM php:8.3-fpm-alpine3.19

LABEL maintainer="michal@sotolar.com"

ARG VERSION=d832907125a7711397da8ade5cfb51082d802542
ARG SHA256=21754aa85eaa4a5de1aba6e076f26ca3c356a4d6e70ae7e1d9e6ea6d12de1d65
ADD https://gitlab.tt-rss.org/tt-rss/tt-rss/-/archive/$VERSION/tt-rss-$VERSION.tar.gz /usr/src/tt-rss.tar.gz

ARG FEEDLY_VERSION=9b50cee70e1ed77d27a273e267c2f50455a23e6f
ARG FEEDLY_SHA256=b88aa875a3e8044ce1ad0b0ecea31fcf65146ed3a79ffca10fce6309bc460083
ADD https://github.com/levito/tt-rss-feedly-theme/archive/$FEEDLY_VERSION.tar.gz /usr/src/tt-rss-feedly-theme.tar.gz

ENV PHP_MAX_EXECUTION_TIME 300
ENV PHP_MEMORY_LIMIT 64M

ENV TTRSS_MYSQL_CHARSET="UTF8"
ENV TTRSS_PHP_EXECUTABLE="/usr/local/bin/php"
ENV TTRSS_LOCK_DIRECTORY="/usr/local/tt-rss/lock"
ENV TTRSS_CACHE_DIR="/usr/local/tt-rss/cache"
ENV TTRSS_PLUGINS="auth_internal"

WORKDIR /usr/local/tt-rss

RUN set -ex; \
    apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        rsync \
        runit \
        sudo \
        tzdata \
    ; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
        postgresql-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        exif \
        gd \
        intl \
        opcache \
        pcntl \
        pgsql \
        pdo_mysql \
        pdo_pgsql \
        zip \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .tt-rss-rundeps $runDeps; \
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
        echo 'session.auto_start=off'; \
        echo 'session.gc_maxlifetime=21600'; \
        echo 'session.gc_divisor=500'; \
        echo 'session.gc_probability=1'; \
        echo 'zlib.output_compression=Off'; \
    } > $PHP_INI_DIR/conf.d/tt-rss-defaults.ini; \
    \
    { \
        echo 'expose_php=off'; \
        echo 'max_execution_time=${PHP_MAX_EXECUTION_TIME}'; \
        echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/tt-rss-misc.ini; \
    echo "$SHA256 */usr/src/tt-rss.tar.gz" | sha256sum -c -; \
    echo "$FEEDLY_SHA256 */usr/src/tt-rss-feedly-theme.tar.gz" | sha256sum -c -; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY config.php /usr/src/config.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY exclude.txt /usr/src/tt-rss.exclude
COPY service /etc/service

VOLUME /usr/local/tt-rss/html
VOLUME /usr/local/tt-rss/cache
VOLUME /usr/local/tt-rss/conf.d
VOLUME /usr/local/tt-rss/lock

ENTRYPOINT ["entrypoint.sh"]
CMD ["runsvdir", "-P", "/etc/service"]
