#!/bin/bash

if [ ! -d /usr/src/tt-rss ]; then
	mkdir -p /usr/src/tt-rss
	tar -xf /usr/src/tt-rss.tar.gz -C /usr/src/tt-rss --exclude-from=/usr/src/tt-rss.exclude --strip-components=1
fi

if [ ! -e index.php ]; then
	rsync -rlD --delete /usr/src/tt-rss/ /usr/local/tt-rss
else
	rsync -rlD --delete --exclude-from /usr/src/tt-rss.exclude /usr/src/tt-rss/ /usr/local/tt-rss
fi

if [ ! -d /usr/src/ttrss-nginx-xaccel ]; then
	mkdir -p /usr/src/ttrss-nginx-xaccel
	tar -xf /usr/src/ttrss-nginx-xaccel.tar.gz -C /usr/src/ttrss-nginx-xaccel --strip-components=1
fi

rsync -rlD --delete /usr/src/ttrss-nginx-xaccel/ /usr/local/tt-rss/plugins.local/nginx_xaccel

cp /etc/tt-rss/config.php config.php

for d in plugins.local templates.local themes.local; do
	if [ ! -d /usr/local/tt-rss/$d ]; then
		mkdir -p /usr/local/tt-rss/$d
	fi
done

for d in cache lock feed-icons; do
	if [ ! -d /usr/local/tt-rss/$d ]; then
		mkdir -p /usr/local/tt-rss/$d
	fi
	
	chown -R www-data:www-data /usr/local/tt-rss/$d
	chmod 750 /usr/local/tt-rss/$d
	find /usr/local/tt-rss/$d -type f -exec chmod 660 {} \;
done

sudo -u www-data -E /usr/local/bin/php ./update.php --update-schema=force-yes

exec "$@"
