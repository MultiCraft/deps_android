#!/bin/bash -e

. ./sdk.sh
JPEG_VERSION=3.1.2

mkdir -p output/libjpeg/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d libjpeg-src ]; then
	if [ ! -f "$JPEG_VERSION.tar.gz" ]; then
		wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/$JPEG_VERSION.tar.gz
	fi
	tar -xaf $JPEG_VERSION.tar.gz
	mv libjpeg-turbo-$JPEG_VERSION libjpeg-src
	mkdir libjpeg-src/build
fi

cd libjpeg-src/build

cmake .. -DANDROID_STL="c++_static"  \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DCMAKE_INSTALL_PREFIX="." \
	-DENABLE_SHARED=OFF

cmake --build . -j
make install -s

# update `include` folder
rm -rf ../../../../libjpeg/include
cp -r include ../../../output/libjpeg/include
# update lib
rm -rf ../../../output/libjpeg/lib/$TARGET_ABI/libjpeg.a
cp -r libjpeg.a ../../../output/libjpeg/lib/$TARGET_ABI/libjpeg.a

echo "libjpeg build successful"
