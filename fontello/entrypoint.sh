#!/bin/bash

set -e

cp /usr/local/fontello/config/fontello.com.yml.config /usr/local/fontello/config/fontello.com.yml

# replace mount point if env variables are defined
sed -i "s/mount: http:\/\/fontello.com/mount: ${FONTELLO_PROTO:-https}:\/\/${FONTELLO_HOST:-fontello.com}/" /usr/local/fontello/config/fontello.com.yml

# uncomment `forwarded: true`
sed -i "s/#forwarded: true/forwarded: true/" /usr/local/fontello/config/fontello.com.yml

exec "$@"