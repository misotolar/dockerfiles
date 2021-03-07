#!/bin/sh

locale-gen

if [ -n "$USER_DISK_GID" ]; then
    if [ "$USER_DISK_GID" != $(getent group disk | cut -d: -f3) ]; then
        groupmod -g "$USER_DISK_GID" disk
    fi
fi

if [ -n "$USER_DIALOUT_GID" ]; then
    if [ "$USER_DIALOUT_GID" != $(getent group dialout | cut -d: -f3) ]; then
        groupmod -g "$USER_DIALOUT_GID" dialout
    fi
fi

if [ -n "$USER_VIDEO_GID" ]; then
    if [ "$USER_VIDEO_GID" != $(getent group video | cut -d: -f3) ]; then
        groupmod -g "$USER_VIDEO_GID" video
    fi
fi

if ! id -u "$PHP_USER" > /dev/null 2>&1; then
    adduser --quiet --disabled-password --uid "$PHP_USER_UID" --shell /bin/bash --home /home/"$PHP_USER" --gecos "$PHP_USER_GECOS" "$PHP_USER"
    usermod -aG dialout,disk,video,sudo "$PHP_USER"
fi

envsubst < "/etc/php/$PHP_VERSION/fpm/php-fpm.conf.docker" > "/etc/php/$PHP_VERSION/fpm/php-fpm.conf"
/usr/sbin/php-fpm"$PHP_VERSION"