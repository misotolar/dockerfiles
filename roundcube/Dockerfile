FROM php:7.4-fpm-alpine

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.4.11
ARG SHA256=ac7319070c305fc2c88c7723605562d8607030732beee931cdb4091cf05e69b7
ARG URL=https://github.com/roundcube/roundcubemail/releases/download/${VERSION}/roundcubemail-${VERSION}-complete.tar.gz

ENV MAX_EXECUTION_TIME 300
ENV MEMORY_LIMIT 64M
ENV UPLOAD_LIMIT 2048K

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
    docker-php-ext-enable imagick; \
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
    echo 'session.auto_start=Off'; \
        echo 'session.gc_maxlifetime=21600'; \
        echo 'session.gc_divisor=500'; \
        echo 'session.gc_probability=1'; \
        echo 'zlib.output_compression=Off'; \
    } > $PHP_INI_DIR/conf.d/roundcube-defaults.ini; \
    \
    { \
        echo 'max_execution_time=${MAX_EXECUTION_TIME}'; \
        echo 'memory_limit=${MEMORY_LIMIT}'; \
        echo 'post_max_size=${UPLOAD_LIMIT}'; \
        echo 'upload_max_filesize=${UPLOAD_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/roundcube-misc.ini; \
    apk add --no-cache --virtual .fetch-deps \
        gnupg \
    ; \
    export GNUPGHOME="$(mktemp -d)"; \
    export GPGKEY="F3E4C04BB3DB5D4215C45F7F5AB2BAA141C4F7D5"; \
    echo "disable-ipv6" > "$GNUPGHOME/dirmngr.conf"; \
    curl -fsSL -o roundcubemail.tar.gz $URL; \
    curl -fsSL -o roundcubemail.tar.gz.asc $URL.asc; \
    echo "$SHA256 *roundcubemail.tar.gz" | sha256sum -c -; \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keys.gnupg.net --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver pgp.mit.edu --recv-keys "$GPGKEY" \
        || gpg --batch --keyserver keyserver.pgp.com --recv-keys "$GPGKEY"; \
    gpg --batch --verify roundcubemail.tar.gz.asc roundcubemail.tar.gz; \
    gpgconf --kill all; \
    mkdir -p /usr/src/roundcubemail; \
    tar -xf roundcubemail.tar.gz -C /usr/src/roundcubemail --strip-components=1 --no-same-owner; \
    chown -R www-data:www-data /usr/src/roundcubemail/logs; \
    curl -fsSL -o /tmp/composer-installer.php https://getcomposer.org/installer; \
    php /tmp/composer-installer.php --install-dir=/usr/local/bin; \
    apk del --no-network .fetch-deps; \
    rm -rf \
        roundcube.tar.gz \
        roundcube.tar.gz.asc \
        /usr/src/roundcubemail/installer \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME /var/www/html
VOLUME /var/roundcube/config
VOLUME /var/roundcube/db
VOLUME /tmp/roundcube

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
