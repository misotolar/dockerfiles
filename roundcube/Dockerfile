FROM php:7.4-fpm-alpine3.15

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.5.2
ARG SHA256=f03968381156fe790d858af7e069c5550a8577fb964f96624434895272053838
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
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-configure ldap; \
    docker-php-ext-install \
        exif \
        gd \
        intl \
        ldap \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        zip \
    ; \
    pecl install imagick; \
    pecl install redis; \
    docker-php-ext-enable imagick redis; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .roundcube-rundeps $runDeps; \
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
