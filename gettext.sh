#!/bin/bash -e

. ./sdk.sh
GETTEXT_VERSION=0.24.1

mkdir -p output/gettext/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d gettext-src ]; then
	if [ ! -f "gettext-$GETTEXT_VERSION.tar.xz" ]; then
		wget https://ftp.gnu.org/pub/gnu/gettext/gettext-$GETTEXT_VERSION.tar.xz
	fi
	tar -xaf gettext-$GETTEXT_VERSION.tar.xz
	mv gettext-$GETTEXT_VERSION gettext-src
fi

cd gettext-src/gettext-runtime

./configure --host=$TARGET CFLAGS="$CFLAGS" CPPFLAGS="$CXXFLAGS" \
	--prefix=/ --disable-shared --enable-static \
	--disable-libasprintf

make -j

# update `include` folder
rm -rf ../../../output/gettext/include
mkdir -p ../../../output/gettext/include
cp -r intl/libintl.h ../../../output/gettext/include/libintl.h
# update lib
rm -rf ../../../output/gettext/lib/$TARGET_ABI/libintl.a
cp -r intl/.libs/libintl.a ../../../output/gettext/lib/$TARGET_ABI/libintl.a

echo "Gettext build successful"
