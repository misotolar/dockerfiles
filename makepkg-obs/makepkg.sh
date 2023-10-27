#!/bin/bash

set -e

sudo pacman -Syu --noconfirm

if [[ -z "$BUILD_PATH" ]]; then
    BUILD_PATH=/drone/src
fi

cp -r "$BUILD_PATH" /tmp/build
cd /tmp/build

if [[ -d /tmp/build/keys/pgp ]]; then
    echo '==> Importing PGP keys...'
    gpg --import /tmp/build/keys/pgp/*.asc
else
    source PKGBUILD
    if [[ ${#validpgpkeys[@]} > 0 ]]; then
        echo '==> Fetching PGP keys...'
        gpg --recv-keys ${validpgpkeys[@]}
    fi
fi

makepkg -o --syncdeps --noconfirm

cd /home/build

echo "user=$OBS_USERNAME" >> /home/build/.config/osc/oscrc
echo "pass=$OBS_PASSWORD" >> /home/build/.config/osc/oscrc

osc checkout "$OBS_PROJECT"
rsync -avu --delete --exclude=".*" --exclude="*/" /tmp/build/ "/home/build/$OBS_PROJECT/$OBS_PACKAGE"

cd "/home/build/$OBS_PROJECT/$OBS_PACKAGE"
osc addremove
if [[ -z "$DRONE_COMMIT_MESSAGE" ]]; then
    osc commit -n
else
    osc commit -m "$DRONE_COMMIT_MESSAGE"
fi
