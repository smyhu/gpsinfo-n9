#!/bin/sh
# Cross-build the gpsinfo-n9 launcher for Nokia N9 (Harmattan PR1.3, ARMv7 hard-float).
# TC: hdr/ (Ubuntu armhf cross headers), qtdev/ (Harmattan SDK libqt4-dev, libqtm-*-dev, libc6-dev),
#     rt/ (N9 device libs), ld-arm (GNU ld wrapper). moc = Harmattan host-moc run under qemu-arm-static.
set -e
TC=${TC:-/tmp/claude-0/x/tc}
D=$(cd "$(dirname "$0")" && pwd)
VER=${VER:-0.1.6}
OUT=${OUT:-$D/build}
mkdir -p $OUT
H=$TC/hdr/usr/arm-linux-gnueabihf
Q=$TC/qtdev/usr/include/qt4
L=$TC/rt/usr/lib
SDKL=$TC/qtdev/usr/lib
QEMU_LD_PREFIX=$TC/rt qemu-arm-static -E LD_LIBRARY_PATH=/usr/lib:/lib $TC/rt/host-moc -I$Q -I$Q/QtMobility $D/src/gps.h -o $OUT/moc_gps.cpp
T="--target=arm-linux-gnueabihf -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard -mthumb"
CF="$T -O2 -fno-pic -nostdinc -isystem $(clang -print-resource-dir)/include -isystem $H/include/c++/13 -isystem $H/include/c++/13/arm-linux-gnueabihf -isystem $H/include -U_FORTIFY_SOURCE -D_FILE_OFFSET_BITS=32"
for f in $D/src/main.cpp $OUT/moc_gps.cpp; do
  clang++ $CF -std=gnu++98 -fno-rtti -fno-exceptions -fno-threadsafe-statics -DQT_NO_DEBUG -DQT_SHARED -DGPSINFO_VERSION=\"$VER\" \
    -I $Q -I $Q/QtCore -I $Q/QtGui -I $Q/QtNetwork -I $Q/QtMobility -I $Q/QtLocation -I $D/src -c $f -o $OUT/$(basename $f .cpp).o
done
G=$TC/hdr/usr/lib/gcc-cross/arm-linux-gnueabihf/13
clang++ $T --ld-path=$TC/ld-arm -no-pie -nostdlib -Wl,--allow-shlib-undefined -Wl,--as-needed -Wl,--hash-style=both -Wl,-z,norelro -Wl,-dynamic-linker,/lib/ld-linux.so.3 \
  $SDKL/crt1.o $SDKL/crti.o $G/crtbegin.o $OUT/main.o $OUT/moc_gps.o \
  $L/libQtLocation.so.1 $L/libQtDeclarative.so.4 $L/libQtNetwork.so.4 $L/libQtGui.so.4 $L/libQtCore.so.4 \
  $L/libstdc++.so.6 $TC/rt/lib/libc.so.6 $SDKL/libc_nonshared.a $TC/rt/lib/libgcc_s.so.1 \
  $G/crtend.o $SDKL/crtn.o -o $OUT/gpsinfo-n9
llvm-strip $OUT/gpsinfo-n9
file $OUT/gpsinfo-n9
