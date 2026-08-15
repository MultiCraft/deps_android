#!/bin/bash -e

BORINGSSL_VERSION=0.20260813.0

. ./sdk.sh

mkdir -p output/boringssl/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d boringssl-src ]; then
	wget -nc -O boringssl-$BORINGSSL_VERSION.tar.gz https://github.com/google/boringssl/archive/refs/tags/$BORINGSSL_VERSION.tar.gz || true
	tar -xaf boringssl-$BORINGSSL_VERSION.tar.gz
	mv boringssl-$BORINGSSL_VERSION boringssl-src
fi

mkdir -p boringssl-src/builddir
cd boringssl-src/builddir

cmake .. \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_TESTING=OFF

cmake --build . -j --target crypto ssl

# update headers
rm -rf ../../../output/boringssl/include/
mkdir -p ../../../output/boringssl/include
cp -r ../include/openssl ../../../output/boringssl/include
# update lib
rm -rf ../../../output/boringssl/lib/$TARGET_ABI/libcrypto.a
cp libcrypto.a ../../../output/boringssl/lib/$TARGET_ABI/libcrypto.a
rm -rf ../../../output/boringssl/lib/$TARGET_ABI/libssl.a
cp libssl.a ../../../output/boringssl/lib/$TARGET_ABI/libssl.a

echo "BoringSSL build successful"
