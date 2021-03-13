#!/bin/sh

envsubst < "/etc/GeoIP.conf.docker" > "/etc/GeoIP.conf"

echo "${GEOIPUPDATE_SCHEDULE} /usr/local/bin/geoipupdate -v -f /etc/GeoIP.conf" > /etc/crontabs/geoipupdate
/usr/local/bin/geoipupdate -v -f /etc/GeoIP.conf

exec "$@"