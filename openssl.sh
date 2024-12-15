#!/bin/bash -e

OPENSSL_VERSION=3.4.0

. sdk.sh

mkdir -p output/openssl/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d openssl-src ]; then
	git clone -b openssl-$OPENSSL_VERSION --depth 1 https://github.com/openssl/openssl.git openssl-src
fi

cd openssl-src

PATH=$TOOLCHAIN/bin:$PATH
./Configure $TARGET_NAME no-tests no-shared
make -j

# update `include` folder
rm -rf ../../output/openssl/include/
cp -r ./include ../../output/openssl/include
# update lib
rm -rf ../../output/openssl/lib/$TARGET_ABI/libcrypto.a
cp -r libcrypto.a ../../output/openssl/lib/$TARGET_ABI/libcrypto.a
rm -rf ../../output/openssl/lib/$TARGET_ABI/libssl.a
cp -r libssl.a ../../output/openssl/lib/$TARGET_ABI/libssl.a

echo "OpenSSL build successful"
