#!/bin/sh

if [[ $UID -ne 0 ]]; then
    /usr/bin/sudo true
fi

CURRENT=$(dirname "$0")
INSTALL=()

for FILENAME in $CURRENT/*.deb; do
    PACKAGE="${FILENAME##*/}"
    PACKAGE="${PACKAGE%%_*}"

    /usr/bin/dpkg -l | /usr/bin/grep "$PACKAGE" | /usr/bin/grep -q ii && INSTALL+=("$FILENAME")
done

if [[ ${INSTALL[@]} ]]; then
    /usr/bin/sudo /usr/bin/dpkg -i "${INSTALL[@]}"
fi
