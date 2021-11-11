#!/bin/bash

tar -xf /usr/src/repman.tar.gz -C . --exclude-from=/usr/src/repman.exclude --strip-components=1
chown www-data:www-data /usr/local/repman/{public,var}

composer install --optimize-autoloader --no-dev --no-scripts

sudo -u www-data -E /usr/local/bin/repman assets:install --relative
sudo -u www-data -E /usr/local/bin/repman d:m:m --no-interaction
sudo -u www-data -E /usr/local/bin/repman messenger:setup-transports --no-interaction
sudo -u www-data -E /usr/local/bin/repman repman:security:update-db

exec "$@"
