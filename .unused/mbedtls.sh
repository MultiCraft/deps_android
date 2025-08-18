#!/bin/bash -e

. ./sdk.sh
MBEDTLS_VERSION=3.6.1

mkdir -p output/mbedtls/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d mbedtls-src ]; then
	git clone -b v$MBEDTLS_VERSION --depth 1 https://github.com/Mbed-TLS/mbedtls mbedtls-src
	mkdir mbedtls-src/build
	cd mbedtls-src
	git submodule update --init
	cd -
fi

cd mbedtls-src/build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DBUILD_SHARED_LIBS=OFF \
	-DANDROID_ARM_MODE="arm" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS -fPIC" \
	-DCMAKE_INSTALL_PREFIX="." \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DENABLE_TESTING=OFF \
	-DENABLE_PROGRAMS=OFF

cmake --build . -j
make install -s

# update lib
rm -rf ../../../output/mbedtls/lib/$TARGET_ABI/*.a
cp -r library/*.a ../../../output/mbedtls/lib/$TARGET_ABI/

echo "MbedTLS build successful"
