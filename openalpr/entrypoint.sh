#!/bin/sh

exec /usr/bin/beanstalkd -l "$BEANSTALKD_LISTEN_ADDR" -p "$BEANSTALKD_LISTEN_PORT" -u nobody