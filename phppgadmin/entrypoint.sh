#!/bin/bash

if [ ! -z "${HIDE_PHP_VERSION}" ]; then
    echo "PHP version is now hidden."
    echo -e 'expose_php = Off\n' > $PHP_INI_DIR/conf.d/phppgadmin-hide-php-version.ini
fi

tar -xf /usr/src/phpPgAdmin.tar.gz -C /var/www/html --exclude-from=/usr/src/phpPgAdmin.exclude --strip-components=1
ln -fs /etc/phppgadmin/config.inc.php /var/www/html/conf/config.inc.php

exec "$@"
