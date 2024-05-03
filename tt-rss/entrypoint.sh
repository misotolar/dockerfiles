#!/bin/bash

set -ex

if [ ! -d /usr/src/tt-rss ]; then
	mkdir -p /usr/src/tt-rss
	tar -xf /usr/src/tt-rss.tar.gz -C /usr/src/tt-rss --exclude-from=/usr/src/tt-rss.exclude --strip-components=1
fi

if [ ! -d /usr/src/tt-rss-nginx-xaccel ]; then
	mkdir -p /usr/src/tt-rss-nginx-xaccel
	tar -xf /usr/src/tt-rss-nginx-xaccel.tar.gz -C /usr/src/tt-rss-nginx-xaccel --exclude-from=/usr/src/tt-rss.exclude --strip-components=1
fi

if [ ! -d /usr/src/tt-rss-feedly-theme ]; then
	mkdir -p /usr/src/tt-rss-feedly-theme
	tar -xf /usr/src/tt-rss-feedly-theme.tar.gz -C /usr/src/tt-rss-feedly-theme --exclude-from=/usr/src/tt-rss.exclude --strip-components=1
fi

rsync -rlD --delete --exclude-from /usr/src/tt-rss.exclude /usr/src/tt-rss/ /usr/local/tt-rss/html
rsync -rlD --delete --exclude-from /usr/src/tt-rss.exclude /usr/src/tt-rss-nginx-xaccel/ /usr/local/tt-rss/html/plugins.local/nginx_xaccel
rsync -rlD --delete --exclude-from /usr/src/tt-rss.exclude /usr/src/tt-rss-feedly-theme/ /usr/local/tt-rss/html/themes.local

mkdir -p /usr/local/tt-rss/conf.d
cp /usr/src/config.php /usr/local/tt-rss/html/config.php

for d in plugins.local templates.local themes.local; do
	if [ ! -d /usr/local/tt-rss/html/$d ]; then mkdir -p /usr/local/tt-rss/html/$d; fi
done

for d in "$TTRSS_CACHE_DIR" "$TTRSS_CACHE_DIR"/export "$TTRSS_CACHE_DIR"/feeds "$TTRSS_CACHE_DIR"/images "$TTRSS_CACHE_DIR"/upload "$TTRSS_LOCK_DIRECTORY" /usr/local/tt-rss/html/feed-icons; do
	if [ ! -d $d ]; then mkdir -p $d; fi

	chmod 0750 $d && find $d -type f -exec chmod 666 {} \;
	chown -R www-data:www-data $d
done

sudo -u www-data -E "$TTRSS_PHP_EXECUTABLE" /usr/local/tt-rss/html/update.php --update-schema=force-yes

export TTRSS_PHP_EXECUTABLE

exec "$@"
