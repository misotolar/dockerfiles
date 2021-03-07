#!/bin/sh

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

if ! id -u "$USER_NAME" > /dev/null 2>&1; then
    adduser --quiet --disabled-password --uid "$USER_UID" --shell /bin/bash --home /home/"$USER_NAME" --gecos "$USER_GECOS" "$USER_NAME"
    usermod -aG dialout,disk,video,sudo "$USER_NAME"
fi

locale-gen

envsubst < "/etc/php/$PHP_VERSION/fpm/php-fpm.conf.docker" > "/etc/php/$PHP_VERSION/fpm/php-fpm.conf"
/usr/sbin/php-fpm"$PHP_VERSION"