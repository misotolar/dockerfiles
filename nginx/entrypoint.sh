#!/bin/bash

set -ex

/usr/local/bin/entrypoint-hooks.sh

NGINX_UUID="${NGINX_UUID:-82}"
if ! id -u www-data > /dev/null 2>&1; then
    adduser -u "$NGINX_UUID" -h /var/www -D -S -G www-data www-data
fi

OCSP_RESPONSE_PATH="${OCSP_RESPONSE_PATH-/usr/local/nginx/cache/ocsp}"
if [[ -d /etc/letsencrypt ]]; then
    /usr/local/sbin/certbot-ocsp-fetcher --output-dir="$OCSP_RESPONSE_PATH" --no-reload-webserver
fi

/usr/local/bin/entrypoint-post-hooks.sh

exec "$@"