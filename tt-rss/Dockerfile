FROM php:8.2-fpm-alpine3.18

LABEL maintainer="michal@sotolar.com"

ARG VERSION=a4543de3ac4b8b4e81f317a5ebb0d88004e3884c
ARG SHA256=b55a58ee0ae21dc571617416bdd3a2b4ae2c7ee218c7c5f761a470f26e130a3b
ADD https://gitlab.tt-rss.org/tt-rss/tt-rss/-/archive/$VERSION/tt-rss-$VERSION.tar.gz /usr/src/tt-rss.tar.gz

ARG TTRSS_NGINX_ACCEL_VERSION=3b4e12ff06cdac025edf45077f79039704779cc6
ARG TTRSS_NGINX_ACCEL_SHA256=67c628c39b4d996e54d259043124a348323a28a008140b919ef2d4816f7a01a5
ADD https://gitlab.tt-rss.org/tt-rss/plugins/ttrss-nginx-xaccel/-/archive/$TTRSS_NGINX_ACCEL_VERSION/ttrss-nginx-xaccel-$TTRSS_NGINX_ACCEL_VERSION.tar.gz /usr/src/ttrss-nginx-xaccel.tar.gz

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
        opcache \
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
