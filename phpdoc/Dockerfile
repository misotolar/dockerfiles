FROM php:8.1.27-cli-alpine3.19

LABEL maintainer="michal@sotolar.com"

ARG VERSION=3.4.3
ARG SHA256=bad7e4b8c99e73391bb3183a127593ecd1cd66ae42b4a33efe495d193e257f04
ADD https://github.com/phpDocumentor/phpDocumentor/releases/download/v$VERSION/phpDocumentor.phar /usr/local/bin/phpdoc

RUN set -ex; \
    apk add --no-cache \
        tzdata \
    ; \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        icu-dev \
    ; \
    docker-php-ext-install -j "$(nproc)" \
        intl \
    ; \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache --virtual .phpdoc-rundeps plantuml $runDeps; \
    apk del --no-network .build-deps; \
    { \
        echo 'memory_limit=-1'; \
    } > $PHP_INI_DIR/conf.d/phpdoc.ini; \
    echo "$SHA256 */usr/local/bin/phpdoc" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/phpdoc; \
    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php.tar.xz.asc \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*;

ENTRYPOINT ["phpdoc"]