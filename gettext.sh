#!/bin/bash -e

. ./sdk.sh
GETTEXT_VERSION=1.0

mkdir -p output/gettext/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d gettext-src ]; then
	wget -nc https://fossies.org/linux/misc/gettext-$GETTEXT_VERSION.tar.xz
	tar -xaf gettext-$GETTEXT_VERSION.tar.xz
	mv gettext-$GETTEXT_VERSION gettext-src
fi

cd gettext-src/gettext-runtime

./configure --host=$TARGET CFLAGS="$CFLAGS" CPPFLAGS="$CXXFLAGS" \
	--prefix=/ --disable-shared --enable-static \
	--disable-libasprintf

make -j

# update headers
rm -rf ../../../output/gettext/include
mkdir -p ../../../output/gettext/include
cp intl/libintl.h ../../../output/gettext/include/libintl.h

# update lib
rm -rf ../../../output/gettext/lib/$TARGET_ABI/libintl.a
cp intl/.libs/libintl.a ../../../output/gettext/lib/$TARGET_ABI/libintl.a

echo "Gettext build successful"
