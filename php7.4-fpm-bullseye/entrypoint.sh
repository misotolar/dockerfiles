#!/bin/sh

locale-gen

if ! id -u "$PHP_USER" > /dev/null 2>&1; then
    adduser --quiet --disabled-password --uid "$PHP_USER_UID" --shell /bin/bash --home /home/"$PHP_USER" --gecos "$PHP_USER_GECOS" "$PHP_USER"
    echo "$PHP_USER ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/"$PHP_USER"
    touch /home/"$PHP_USER"/.sudo_as_admin_successful
    usermod -aG sudo "$PHP_USER"
fi

envsubst < "/etc/php/php-fpm.conf" > "/etc/php/$PHP_VERSION/fpm/php-fpm.conf"

exec "$@"