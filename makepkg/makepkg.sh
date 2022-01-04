#!/bin/bash

set -e

if [[ -z "$BUILD_PATH" ]]; then
    if [[ ! -z "$DRONE_STEP_NAME" ]]; then
        BUILD_PATH=/drone/src/"$DRONE_STEP_NAME"
    else
        prinf "Build path not set.\n"
        exit 1
    fi
fi

if [[ -z "$EXPORT_PATH" ]]; then
    if [[ ! -z "$DRONE_STEP_NAME" ]]; then
        EXPORT_PATH=/drone/src/export
    else
        EXPORT_PATH=/home/build
    fi
fi

if [[ ! -d "$EXPORT_PATH" ]]; then
    sudo mkdir -p "$EXPORT_PATH"
    sudo chown "$(stat -c '%u:%g' "$BUILD_PATH"/PKGBUILD)" "$EXPORT_PATH"
fi

cp -r "$BUILD_PATH" /tmp/build
cd /tmp/build

source PKGBUILD
if [[ ${#validpgpkeys[@]} > 0 ]]; then
    echo '==> Fetching PGP keys...'
    gpg --recv-keys ${validpgpkeys[@]}
fi

paru -U --noconfirm
sudo chown "$(stat -c '%u:%g' "$BUILD_PATH"/PKGBUILD)" ./*pkg.tar*
sudo mv ./*.pkg.tar* "$EXPORT_PATH"
