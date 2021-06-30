#!/bin/sh

if [ "${ASTERISK_USER_ID}" != "" ] && [ "${ASTERISK_GROUP_ID}" != "" ]; then
    deluser asterisk && \
    addgroup -g ${ASTERISK_GROUP_ID} ${ASTERISK_GROUP} && \
    adduser -D -H -u ${ASTERISK_USER_ID} -G ${ASTERISK_GROUP} ${ASTERISK_USER} \
    || exit
fi

chown -R ${ASTERISK_USER}:${ASTERISK_GROUP} \
    /etc/asterisk \
    /var/log/asterisk \
    /var/lib/asterisk \
    /var/run/asterisk \
    /var/spool/asterisk

exec "$@"
