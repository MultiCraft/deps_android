#!/bin/bash -e

OPENSSL_VERSION=3.6.1

. ./sdk.sh

mkdir -p output/openssl/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d openssl-src ]; then
	wget -nc https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz
	tar -xzf openssl-$OPENSSL_VERSION.tar.gz
	mv openssl-$OPENSSL_VERSION openssl-src
fi

cd openssl-src

CFLAGS="$CFLAGS -fvisibility=hidden -fvisibility-inlines-hidden"
PATH=$TOOLCHAIN/bin:$PATH
dos2unix Configure
./Configure $TARGET_NAME no-tests no-shared -U__ANDROID_API__ -D__ANDROID_API__=$API
make -j

# update headers
rm -rf ../../output/openssl/include/
echo $PWD
mkdir -p ../../output/openssl/include
cp -r include/openssl ../../output/openssl/include
# update lib
rm -rf ../../output/openssl/lib/$TARGET_ABI/libcrypto.a
cp libcrypto.a ../../output/openssl/lib/$TARGET_ABI/libcrypto.a
rm -rf ../../output/openssl/lib/$TARGET_ABI/libssl.a
cp libssl.a ../../output/openssl/lib/$TARGET_ABI/libssl.a

echo "OpenSSL build successful"
