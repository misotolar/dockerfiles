FROM php:8.1-fpm-alpine3.18

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.6.5
ARG SHA256=164b72cb78de89d104741ee9090f4024e63bfada43949034844365f3fa70b5fd
ADD https://github.com/roundcube/roundcubemail/releases/download/${VERSION}/roundcubemail-${VERSION}-complete.tar.gz /usr/src/roundcubemail.tar.gz

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

ENV MAX_EXECUTION_TIME 300
ENV MEMORY_LIMIT 64M
ENV UPLOAD_LIMIT 2048K

WORKDIR /usr/local/roundcube

RUN set -ex; \
    apk add --no-cache \
        bash \
        coreutils \
        rsync \
        tzdata; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        freetype-dev \
        icu-dev \
        imagemagick-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
        libtool \
        openldap-dev \
        postgresql-dev \
        sqlite-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-configure ldap; \
    docker-php-ext-install \
        exif \
        gd \
        intl \
        ldap \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        zip \
    ; \
    pecl install imagick redis; \
    docker-php-ext-enable imagick opcache redis; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .roundcube-rundeps imagemagick $runDeps; \
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
        echo 'output_buffering=on'; \
        echo 'zlib.output_compression=off'; \
    } > $PHP_INI_DIR/conf.d/roundcube-defaults.ini; \
    \
    { \
        echo 'expose_php=off'; \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/roundcube-misc.ini; \
    echo "$SHA256 */usr/src/roundcubemail.tar.gz" | sha256sum -c -; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY exclude.txt /usr/src/roundcubemail.exclude
COPY config.inc.php /usr/src/config.inc.php

VOLUME /usr/local/roundcube

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
