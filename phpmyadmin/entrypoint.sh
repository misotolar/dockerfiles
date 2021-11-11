#!/bin/sh

if [ ! -f /etc/phpmyadmin/config.secret.inc.php ]; then
   cat > /etc/phpmyadmin/config.secret.inc.php <<EOT
<?php
\$cfg['blowfish_secret'] = '$(tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' < /dev/urandom | fold -w 32 | head -n 1)';
EOT
fi

tar -xf /usr/src/phpMyAdmin.tar.xz -C . --exclude-from=/usr/src/phpMyAdmin.exclude --strip-components=1
sed -i "s@define('CONFIG_DIR'.*@define('CONFIG_DIR', '/etc/phpmyadmin/');@" /usr/local/phpmyadmin/libraries/vendor_config.php
mkdir -p /usr/local/phpmyadmin/tmp; chown www-data:www-data /usr/local/phpmyadmin/tmp

exec "$@"
