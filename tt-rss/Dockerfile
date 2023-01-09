FROM php:8.1-fpm-alpine3.17

LABEL maintainer="michal@sotolar.com"

ARG VERSION=c30b24d09f4096e612965af658540595262f6848
ARG SHA256=71bc735b556c12585cea2dc4bbaac0ad67ae50ead9fbf083be6e81306c0e0644
ADD https://dev.tt-rss.org/fox/tt-rss/archive/$VERSION.tar.gz /usr/src/tt-rss.tar.gz

ARG TTRSS_NGINX_ACCEL_VERSION=fa76dda65d080b46928a70d1f02cfda35e981056
ARG TTRSS_NGINX_ACCEL_SHA256=0ef2d038e21f108696165d6ba124a5e64f4b22d6418d867515388641c2d2a74c
ADD https://dev.tt-rss.org/fox/ttrss-nginx-xaccel/archive/$TTRSS_NGINX_ACCEL_VERSION.tar.gz /usr/src/ttrss-nginx-xaccel.tar.gz

ENV PHP_MAX_EXECUTION_TIME 300
ENV PHP_MEMORY_LIMIT 64M

ENV TTRSS_MYSQL_CHARSET="UTF8"
ENV TTRSS_PHP_EXECUTABLE="/usr/local/bin/php"
ENV TTRSS_PLUGINS="auth_internal"

WORKDIR /usr/local/tt-rss

RUN set -ex; \
    apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        rsync \
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
        pcntl \
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
    echo "$TTRSS_NGINX_ACCEL_SHA256 */usr/src/ttrss-nginx-xaccel.tar.gz" | sha256sum -c -; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

WORKDIR /usr/local/tt-rss

COPY config.php /etc/tt-rss/config.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY exclude.txt /usr/src/tt-rss.exclude

VOLUME /usr/local/tt-rss

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
