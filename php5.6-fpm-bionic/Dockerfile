FROM ubuntu:bionic

LABEL maintainer="michal@sotolar.com"

ENV PHP_USER bionic
ENV PHP_USER_UID 1000
ENV PHP_USER_GECOS Ubuntu Bionic
ENV PHP_FPM_LISTEN 0.0.0.0:9000

ENV PHP_VERSION 5.6
ENV PHP_VERSION_DATE 20131226
ENV PHP_PACKAGE_VERSION 5.6.40-52

ENV PHP_DIO_VERSION 0.2.0
ENV PHP_EVENT_VERSION 3.0.4

ARG ACCEPT_EULA=Y
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN set -ex; \
    apt-get update -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        gnupg \
        locales; \
    locale-gen "es_ES.UTF-8"; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse" | tee /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list; \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list; \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        gettext-base \
        joe \
        libevent-2.1-6 \
        libevent-extra-2.1-6 \
        libevent-openssl-2.1-6 \
        libevent-pthreads-2.1-6 \
        libevent-dev \
        locales \
        minicom \
        php-pear \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-dev \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-interbase \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mcrypt \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zmq \
        tzdata \
        sudo; \
    ln -fs /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm; \
    pecl install \
        dio-${PHP_DIO_VERSION} \
        event-${PHP_EVENT_VERSION}; \
    echo "extension = dio.so" | tee /etc/php/${PHP_VERSION}/mods-available/dio.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/dio.ini /etc/php/${PHP_VERSION}/cli/conf.d/50-dio.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/dio.ini /etc/php/${PHP_VERSION}/fpm/conf.d/50-dio.ini; \
    echo "extension = event.so" | tee /etc/php/${PHP_VERSION}/mods-available/event.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/event.ini /etc/php/${PHP_VERSION}/cli/conf.d/50-event.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/event.ini /etc/php/${PHP_VERSION}/fpm/conf.d/50-event.ini; \
    curl -fsSL -o /tmp/sourceguardian.tar.gz http://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz; \
    tar --extract --file=/tmp/sourceguardian.tar.gz --directory=/usr/lib/php/${PHP_VERSION_DATE} ixed.${PHP_VERSION}.lin; \
    echo "zend_extension = ixed.${PHP_VERSION}.lin" | tee /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini /etc/php/${PHP_VERSION}/cli/conf.d/50-sourceguardian.ini; \
    ln -fs /etc/php/${PHP_VERSION}/mods-available/sourceguardian.ini /etc/php/${PHP_VERSION}/fpm/conf.d/50-sourceguardian.ini; \
    apt-get remove --purge -y \
        build-essential \
        curl \
        dpkg-dev \
        gnupg \
        libevent-dev \
        php-pear \
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
