#!/bin/sh
# make-deb.sh - builds gpsinfo-n9_<VER>_armel.deb from build/gpsinfo-n9 + qml/ + packaging/
set -e
D=$(cd "$(dirname "$0")/.." && pwd)
VER=${VER:-0.1.6}
OUTDIR=${OUTDIR:-$D/dist}
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
P=$T/data; mkdir -p $P/opt/gpsinfo-n9/bin $P/opt/gpsinfo-n9/qml $P/usr/share/applications $P/usr/share/icons/hicolor/80x80/apps $P/usr/share/doc/gpsinfo-n9 $T/ctl
install -m 755 $D/build/gpsinfo-n9 $P/opt/gpsinfo-n9/bin/
install -m 644 $D/qml/* $P/opt/gpsinfo-n9/qml/
install -m 644 $D/packaging/gpsinfo-n9.desktop $P/usr/share/applications/
install -m 644 $D/qml/gpsinfo-n9.png $P/usr/share/icons/hicolor/80x80/apps/
install -m 644 $D/LICENSE $P/usr/share/doc/gpsinfo-n9/copyright
SIZE=$(du -sk $P | cut -f1)
cat > $T/ctl/control <<CTL
Package: gpsinfo-n9
Version: $VER
Architecture: armel
Maintainer: smyhu <smyhu@users.noreply.github.com>
Installed-Size: $SIZE
Depends: libc6 (>= 2.10), libqtcore4 (>= 4.7.4~), libqtgui4 (>= 4.7.4~), libqt4-declarative (>= 4.7.4~), libqtm-location (>= 1.2.1), libqtm-sensors (>= 1.2.1), qt-components (>= 1.0)
Section: user/navigation
Priority: optional
Homepage: https://github.com/smyhu/gpsinfo-n9
Description: GPS status: satellites, position, accuracy and averages
 Shows satellites in view and in use with signal strength, a sky plot turned
 by the compass, position, speed, accuracy, averages and a small map.
 The status box never blocks the screen. Languages: en, pl, de, es, it, fr.
 Designed and written by Claude (Anthropic) together with smyhu for the Nokia N9.
Maemo-Display-Name: GPS Info
Maemo-Flags: visible
CTL
printf 'Maemo-Icon-26: %s\n' "$(base64 -w0 $D/qml/gpsinfo-n9.png)" >> $T/ctl/control
(cd $P && find . -type f | sed 's#^\./##' | sort | xargs md5sum) > $T/ctl/md5sums
wpis() { printf 'S 15 com.nokia.maemo H 40 %s R %d %s\n' "$1" "${#2}" "$2"; }
(cd $P && find . -type f | sed 's#^\./##' | grep -v '^usr/share/' | sort | while read -r f; do wpis "$(sha1sum "$f" | cut -d' ' -f1)" "$f"; done) > $T/ctl/digsigsums
(cd $T/ctl && tar czf ../control.tar.gz --owner=0 --group=0 --numeric-owner --format=gnu ./control ./md5sums ./digsigsums)
(cd $P && tar czf ../data.tar.gz --owner=0 --group=0 --numeric-owner --format=gnu .)
echo 2.0 > $T/debian-binary
cp $D/packaging/_aegis $T/_aegis
mkdir -p $OUTDIR; DEB=$OUTDIR/gpsinfo-n9_${VER}_armel.deb; rm -f $DEB
(cd $T && ar rc $DEB debian-binary control.tar.gz data.tar.gz _aegis)
md5sum $DEB
