FROM debian:buster-slim

LABEL maintainer="michal@sotolar.com"

ENV PHP_USER buster
ENV PHP_USER_UID 1000
ENV PHP_USER_GECOS Debian Buster
ENV PHP_FPM_LISTEN 0.0.0.0:9000

ENV PHP_VERSION 7.4
ENV PHP_PACKAGE_VERSION 7.4.27-1

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN set -ex; \
    apt-get update -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        gnupg \
        locales; \
    locale-gen "es_ES.UTF-8"; \
    echo "deb http://deb.debian.org/debian buster main contrib non-free" | tee /etc/apt/sources.list; \
    echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb http://security.debian.org/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list; \
    echo "deb https://packages.sury.org/php/ buster main" >> /etc/apt/sources.list; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B188E2B695BD4743; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        curl \
        gettext-base \
        joe \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-apcu-bc \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-odbc \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-xml \
        sudo \
        tzdata; \
    ln -fs /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm; \
    curl -fsSL -o /tmp/sourceguardian.tar.gz http://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz; \
    tar xf /tmp/sourceguardian.tar.gz -C $(php-config --extension-dir) ixed.${PHP_VERSION}.lin; \
    echo "zend_extension = ixed.${PHP_VERSION}.lin" | tee /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini /etc/php/${PHP_VERSION}/cli/conf.d/50-sourceguardian.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini /etc/php/${PHP_VERSION}/fpm/conf.d/50-sourceguardian.ini; \
    apt-get remove --purge -y \
        curl \
        gnupg \
        php${PHP_VERSION}-dev; \
    apt-get autoremove --purge -y; \
    apt-get clean autoclean -y; \
    rm -rf \
        /etc/php/${PHP_VERSION}/fpm/pool.d \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

ENV LANG=es_ES.UTF-8
ENV LANGUAGE=es_ES.UTF-8
ENV LC_ALL=es_ES.UTF-8

COPY php-fpm.conf /etc/php/php-fpm.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

STOPSIGNAL SIGQUIT
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm"]
