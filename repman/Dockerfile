FROM php:7.4-fpm-alpine3.15

LABEL maintainer="michal@sotolar.com"

ARG VERSION=1.4.0
ARG SHA256=718480be5f5e2b4d5fa9702f2e4e62c02e67928da2f360e0d99def99b0bbf84e
ADD https://github.com/repman-io/repman/archive/refs/tags/${VERSION}.tar.gz /usr/src/repman.tar.gz

ENV APP_ENV prod
ENV APP_DEBUG 0

ENV PHP_MEMORY_LIMIT 512M

WORKDIR /usr/local/repman

RUN set -ex; \
    apk add --no-cache \
        bash \
        git \
        openssh-client \
        runit \
        sudo \
        zip \
        unzip \
    ; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
        libzip-dev \
        postgresql-dev \
    ; \
    docker-php-ext-install \
        intl \
        pdo_pgsql \
        zip \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .repman-rundeps $runDeps; \
    apk del --no-network .build-deps; \
    \
    { \
        echo 'session.cookie_httponly=1'; \
        echo 'session.use_strict_mode=1'; \
    } > $PHP_INI_DIR/conf.d/session-strict.ini; \
    \
    { \
        echo 'expose_php=off'; \
        echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
    } > $PHP_INI_DIR/conf.d/repman-misc.ini; \
    { \
        echo 'Host *'; \
        echo 'StrictHostKeyChecking no'; \
    } > /etc/ssh/ssh_config; \
    echo "$SHA256 */usr/src/repman.tar.gz" | sha256sum -c -; \
    ln -sf /usr/local/repman/bin/console /usr/local/bin/repman; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY exclude.txt /usr/src/repman.exclude
COPY service /etc/service

VOLUME /usr/local/repman

ENTRYPOINT ["entrypoint.sh"]
CMD ["runsvdir", "-P", "/etc/service"]
