#!/bin/sh

envsubst < "/etc/GeoIP.conf.docker" > "/etc/GeoIP.conf"

echo "${GEOIPUPDATE_SCHEDULE} /usr/local/bin/geoipupdate -v -f /etc/GeoIP.conf" > /etc/crontabs/geoipupdate
if [ ! -z "${GEOIPUPDATE_XTABLES_SCHEDULE}" ]; then
    echo "${GEOIPUPDATE_XTABLES_SCHEDULE} /usr/local/bin/xt-update.sh" >> /etc/crontabs/geoipupdate
fi

/usr/local/bin/geoipupdate -v -f /etc/GeoIP.conf
if [ ! -z "${GEOIPUPDATE_XTABLES_SCHEDULE}" ]; then
    /usr/local/bin/xt-update.sh
fi

exec "$@"