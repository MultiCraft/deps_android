#!/bin/bash -e

. sdk.sh
CURL_VERSION=8.11.0

export ANDR_ROOT=$(pwd)

mkdir -p output/libcurl/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d libcurl-src ]; then
	wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz
	tar -xzf curl-$CURL_VERSION.tar.gz
	mv curl-$CURL_VERSION libcurl-src
	rm curl-$CURL_VERSION.tar.gz
fi

cd libcurl-src

CFLAGS="-I$ANDR_ROOT/deps/openssl-src/include -L$ANDR_ROOT/deps/openssl-src $CFLAGS" \
./configure --host=$TARGET \
	--with-openssl \
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

# update `include` folder
rm -rf ../../output/libcurl/include
cp -r include ../../output/libcurl/
# update lib
rm -rf ../../output/libcurl/lib/$TARGET_ABI/libcurl.a
cp -r lib/.libs/libcurl.a ../../output/libcurl/lib/$TARGET_ABI/

echo "libcurl build successful"
