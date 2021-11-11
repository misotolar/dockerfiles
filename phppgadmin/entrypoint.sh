#!/bin/sh

tar -xf /usr/src/phpPgAdmin.tar.gz -C . --exclude-from=/usr/src/phpPgAdmin.exclude --strip-components=1
ln -fs /usr/local/etc/phppgadmin/config.inc.php /usr/local/phppgadmin/conf/config.inc.php

exec "$@"
