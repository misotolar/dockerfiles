#!/bin/sh

set -ex

sed -i \
    -e "/CRYPTO_80211_/s/^#define/#undef/" \
    -e "/IWMGMT_CMD/c #undef IWMGMT_CMD" \
    -e "/PING_CMD/c #define PING_CMD" \
    -e "/POWEROFF_CMD/c #define POWEROFF_CMD" \
    -e "/REBOOT_CMD/c #define REBOOT_CMD" \
    -e "/DOWNLOAD_PROTO_HTTPS/c #define DOWNLOAD_PROTO_HTTPS" \
    config/general.h

sed -i "/COLOR_[A-Z]*_BG/s/COLOR_BLUE/COLOR_BLACK/" config/colour.h
sed -i "/OCSP_CHECK/c #undef OCSP_CHECK" config/crypto.h

if [ ! -f "$@"/embed.ipxe ]; then
    make bin/ipxe.lkrn
    make bin/undionly.kpxe
    make bin-i386-efi/ipxe.efi
    make bin-x86_64-efi/ipxe.efi
else
    make bin/ipxe.lkrn EMBED="$@"/embed.ipxe
    make bin/undionly.kpxe EMBED="$@"/embed.ipxe
    make bin-i386-efi/ipxe.efi EMBED="$@"/embed.ipxe
    make bin-x86_64-efi/ipxe.efi EMBED="$@"/embed.ipxe
fi

util/genfsimg -o bin/ipxe.iso \
    bin-x86_64-efi/ipxe.efi \
    bin-i386-efi/ipxe.efi \
    bin/ipxe.lkrn

mkdir -p "$@"
cp -av bin/ipxe.iso "$@"/ipxe.iso
cp -av bin/ipxe.lkrn "$@"/ipxe.lkrn
cp -av bin/undionly.kpxe "$@"/undionly.kpxe
cp -av bin-i386-efi/ipxe.efi "$@"/efi-i386.efi
cp -av bin-x86_64-efi/ipxe.efi "$@"/efi-x86_64.efi

mkdir -p "$@"/syslinux
cp -av /usr/lib/syslinux/memdisk "$@"/syslinux/memdisk