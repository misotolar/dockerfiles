#!/bin/bash

set -e

BACKUPPC_USER=$(getent passwd "$BACKUPPC_UUID" | cut -d: -f1)
BACKUPPC_GROUP=$(getent group "$BACKUPPC_GUID" | cut -d: -f1)

if [ -f /usr/src/backuppc.tar.gz ]; then
    echo 'First run of the container. BackupPC will be installed.'
    echo 'If exist, configuration and data will be reused and upgraded as needed.'
    
    if [ ! -f /bin/bzip2 ]; then
        ln -s /usr/bin/bzip2 /bin/bzip2
    fi

    if [ -z "$BACKUPPC_GROUP" ]; then
        BACKUPPC_GROUP="backuppc"
        groupadd -r -g "$BACKUPPC_GUID" "$BACKUPPC_GROUP"
    fi

    if [ -z "$BACKUPPC_USER" ]; then
        BACKUPPC_USER="backuppc"
		useradd -r -d /home/backuppc -g "$BACKUPPC_GUID" -u "$BACKUPPC_UUID" -M -N "$BACKUPPC_USER"
	else
		usermod -d /home/backuppc "$BACKUPPC_USER"
	fi

	chown "$BACKUPPC_USER":"$BACKUPPC_GROUP" /home/backuppc

    if [ ! -f /home/backuppc/.ssh/id_rsa ]; then
		su "$BACKUPPC_USER" -s /bin/sh -c "ssh-keygen -t rsa -N '' -f /home/backuppc/.ssh/id_rsa"
	fi

    mkdir -p /usr/src/backuppc && cd /usr/src/backuppc
    tar xf /usr/src/backuppc.tar.gz --strip-components=1
    patch -p1 < /usr/src/2c9270b9b849b2c86ae6301dd722c97757bc9256.patch

    perl configure.pl \
        --batch \
        --config-dir /etc/backuppc \
        --cgi-dir /var/www/cgi-bin/BackupPC \
        --data-dir /data/backuppc \
        --log-dir /data/backuppc/log \
        --hostname "$HOSTNAME" \
        --html-dir /var/www/html/BackupPC \
        --html-dir-url /BackupPC \
        --install-dir /usr/local/BackupPC \
        --backuppc-user "$BACKUPPC_USER"

    cd /home/backuppc
    rm -rf /usr/src/*
fi

export BACKUPPC_USER

rsync -rlD --delete /var/www/html/ /var/www/backuppc

exec "$@"