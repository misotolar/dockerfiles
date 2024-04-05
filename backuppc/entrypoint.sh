#!/bin/bash

set -e

BACKUPPC_UUID="${BACKUPPC_UUID:-1000}"
BACKUPPC_GUID="${BACKUPPC_GUID:-1000}"
BACKUPPC_USERNAME=$(getent passwd "$BACKUPPC_UUID" | cut -d: -f1)
BACKUPPC_GROUPNAME=$(getent group "$BACKUPPC_GUID" | cut -d: -f1)

if [ -f /usr/src/backuppc.tar.gz ]; then
    echo 'First run of the container. BackupPC will be installed.'
    echo 'If exist, configuration and data will be reused and upgraded as needed.'
    
    if [ ! -f /bin/bzip2 ]; then
        ln -s /usr/bin/bzip2 /bin/bzip2
    fi

    if [ -z "$BACKUPPC_GROUPNAME" ]; then
        groupadd -r -g "$BACKUPPC_GUID" backuppc
        BACKUPPC_GROUPNAME="backuppc"
    fi

    if [ -z "$BACKUPPC_USERNAME" ]; then
		useradd -r -d /home/backuppc -g "$BACKUPPC_GUID" -u "$BACKUPPC_UUID" -M -N backuppc
		BACKUPPC_USERNAME="backuppc"
	else
		usermod -d /home/backuppc "$BACKUPPC_USERNAME"
	fi

	chown "$BACKUPPC_USERNAME":"$BACKUPPC_GROUPNAME" /home/backuppc

    if [ ! -f /home/backuppc/.ssh/id_rsa ]; then
		su "$BACKUPPC_USERNAME" -s /bin/sh -c "ssh-keygen -t rsa -N '' -f /home/backuppc/.ssh/id_rsa"
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
        --backuppc-user "$BACKUPPC_USERNAME"

    cd /home/backuppc
    rm -rf /usr/src/*
fi

export BACKUPPC_UUID
export BACKUPPC_GUID
export BACKUPPC_USERNAME
export BACKUPPC_GROUPNAME

rsync -rlD --delete /var/www/html/ /var/www/backuppc

exec "$@"