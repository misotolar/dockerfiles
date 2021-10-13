#!/bin/sh

envsubst < "/usr/local/node-media-server/app.template.js" > "/usr/local/node-media-server/app.js"

exec "$@"