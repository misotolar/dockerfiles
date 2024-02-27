#!/bin/bash

set -e

: "${PLUGIN_PORT:=22}"
: "${PLUGIN_SOURCE:=./}"

if [[ -z "$PLUGIN_REMOTE" ]]; then
    print "Remote host not set.\n"
    exit 1
fi

if [[ -z "$PLUGIN_TARGET" ]]; then
    print "Remote target not set.\n"
    exit 1
fi

if [[ -z "$PLUGIN_USERNAME" ]]; then
    print "Remote user not set.\n"
    exit 1
fi

if [[ -z "$PLUGIN_PASSWORD" ]]; then
    print "Remote password not set.\n"
    exit 1
fi

if [[ -z "$PLUGIN_ARGS" ]]; then 
    PLUGIN_ARGS="-az --delete"
fi

EXPR="rsync $PLUGIN_ARGS"
EXPR="$EXPR -e 'sshpass -p %s ssh -p %s -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -o StrictHostKeyChecking=no'"

IFS=','; read -ra INCLUDE <<< "$PLUGIN_INCLUDE"
for include in "${INCLUDE[@]}"; do
    EXPR="$EXPR --include=$include"
done

IFS=','; read -ra EXCLUDE <<< "$PLUGIN_EXCLUDE"
for exclude in "${EXCLUDE[@]}"; do
    EXPR="$EXPR --exclude=$exclude"
done

IFS=','; read -ra FILTER <<< "$PLUGIN_FILTER"
for filter in "${FILTER[@]}"; do
    EXPR="$EXPR --filter=$filter"
done

EXPR="$EXPR $PLUGIN_SOURCE"

eval "$(printf "$EXPR" "$PLUGIN_PASSWORD" "$PLUGIN_PORT") $PLUGIN_USERNAME@$PLUGIN_REMOTE:$PLUGIN_TARGET"
