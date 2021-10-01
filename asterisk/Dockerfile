FROM alpine:3.14

LABEL maintainer="michal@sotolar.com"

ENV ASTERISK_USER=asterisk
ENV ASTERISK_USER_ID=1000
ENV ASTERISK_GROUP=asterisk
ENV ASTERISK_GROUP_ID=1000

RUN set -ex; \
    apk add --update \
        asterisk \
        asterisk-odbc \
        asterisk-sample-config; \
    echo http://dl-2.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories; \
    apk add --update \
        mariadb-connector-odbc; \
    asterisk -U asterisk; \
    sleep 5; \
    pkill -9 asterisk; \
    pkill -9 astcanary; \
    sleep 2; \
    rm -rf /var/run/asterisk/*; \
    truncate -s 0 /var/log/asterisk/messages /var/log/asterisk/queue_log; \
    rm -rf /var/cache/apk/* \
       /tmp/* \
       /var/tmp/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD /usr/sbin/asterisk -T -U ${ASTERISK_USER} -G ${ASTERISK_GROUP} -f -p