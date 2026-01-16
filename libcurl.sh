#!/bin/bash -e

. ./sdk.sh
CURL_VERSION=8.17.0

mkdir -p output/libcurl/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d libcurl-src ]; then
	wget -nc https://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz
	tar -xaf curl-$CURL_VERSION.tar.gz
	mv curl-$CURL_VERSION libcurl-src
fi

cd libcurl-src

INCLUDE_DIRS="-I$ANDR_ROOT/output/openssl/include -I$ANDR_ROOT/output/nghttp2/include"
LIBRARY_DIRS="-L$ANDR_ROOT/output/openssl/lib/$TARGET_ABI -L$ANDR_ROOT/output/nghttp2/lib/$TARGET_ABI"

CFLAGS="$INCLUDE_DIRS $LIBRARY_DIRS $CFLAGS" \
./configure --host=$TARGET \
	--with-openssl \
	--with-nghttp2 \
	--prefix=/ --disable-shared --enable-static \
	--disable-debug --disable-verbose --disable-versioned-symbols \
	--disable-dependency-tracking --disable-libcurl-option \
	--disable-ares --disable-cookies --disable-manual \
	--disable-proxy --disable-unix-sockets --without-librtmp \
	--disable-ftp --disable-ldap --disable-ldaps --disable-rtsp \
	--disable-dict --disable-telnet --disable-tftp --disable-pop3 \
	--disable-imap --disable-smtp --disable-gopher --disable-sspi \
	--without-libpsl

make -j

# update headers
rm -rf ../../output/libcurl/include
cp -r include ../../output/libcurl/
# update lib
rm -rf ../../output/libcurl/lib/$TARGET_ABI/libcurl.a
cp -r lib/.libs/libcurl.a ../../output/libcurl/lib/$TARGET_ABI/libcurl.a

echo "libcurl build successful"
