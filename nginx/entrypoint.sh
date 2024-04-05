#!/bin/bash

set -ex

if [[ -d /etc/letsencrypt ]]; then
    /usr/local/sbin/certbot-ocsp-fetcher --output-dir="$OCSP_RESPONSE_PATH" --no-reload-webserver
fi

exec "$@"