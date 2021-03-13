#!/bin/sh

TMPDIR=$(mktemp -d)

curl -fsSL -o "${TMPDIR}"/geolite.zip https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV\&license_key="${GEOIPUPDATE_LICENSE_KEY}"\&suffix=zip
unzip -q "${TMPDIR}"/geolite.zip -d "${TMPDIR}"

cd "${TMPDIR}"/GeoLite2-Country-CSV_*
xt-build.pl -D "${GEOIPUPDATE_XT_DIR:-"/usr/share/xt_geoip"}"

rm -rf "${TMPDIR}"
exit 0
