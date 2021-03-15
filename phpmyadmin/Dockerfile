FROM php:8.0-fpm-alpine

LABEL maintainer="michal@sotolar.com"

ARG VERSION=5.1.0
ARG SHA256=aa8ccf357f672012384df34e1c2bc70147476761c8458a0dad6233497e142c68
ARG URL=https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.xz

ENV MAX_EXECUTION_TIME 600
ENV MEMORY_LIMIT 512M
ENV UPLOAD_LIMIT 2048K

RUN set -ex; \
    apk add --no-cache \
        bash \
        rsync \
        tzdata; \
    apk add --no-cache --virtual .build-deps \
        bzip2-dev \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxpm-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j "$(nproc)" \
        bz2 \
        gd \
        mysqli \
        opcache \
        zip \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .phpmyadmin-rundeps $runDeps; \
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
    apk add --no-cache --virtual .fetch-deps \
        gnupg \
    ; \
    export GNUPGHOME="$(mktemp -d)"; \
    export GPGKEY="3D06A59ECE730EB71B511C17CE752F178259BD92"; \
    echo "disable-ipv6" > "$GNUPGHOME/dirmngr.conf"; \
    curl -fsSL -o phpMyAdmin.tar.xz $URL; \
    curl -fsSL -o phpMyAdmin.tar.xz.asc $URL.asc; \
    echo "$SHA256 *phpMyAdmin.tar.xz" | sha256sum -c -; \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keys.gnupg.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver pgp.mit.edu --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keyserver.pgp.com --recv-keys "$GPGKEY"; \
    gpg --batch --verify phpMyAdmin.tar.xz.asc phpMyAdmin.tar.xz; \
    gpgconf --kill all; \
    mkdir -p /usr/src/phpmyadmin/tmp; \
    chown www-data:www-data /usr/src/phpmyadmin/tmp; \
    tar -xf phpMyAdmin.tar.xz -C /usr/src/phpmyadmin --strip-components=1; \
    sed -i "s@define('CONFIG_DIR'.*@define('CONFIG_DIR', '/etc/phpmyadmin/');@" /usr/src/phpmyadmin/libraries/vendor_config.php; \
    apk del --no-network .fetch-deps; \
    rm -rf \
        phpMyAdmin.tar.xz \
        phpMyAdmin.tar.xz.asc \
        /usr/src/phpmyadmin/examples \
        /usr/src/phpmyadmin/po \
        /usr/src/phpmyadmin/setup \
        /usr/src/phpmyadmin/test \
        /usr/src/phpmyadmin/composer.json \
        /usr/src/phpmyadmin/RELEASE-DATE-$VERSION \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY config.inc.php /etc/phpmyadmin/config.inc.php
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /var/www/html

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
