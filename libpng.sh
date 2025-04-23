#!/bin/bash -e

. ./sdk.sh
PNG_VERSION=1.6.47

mkdir -p output/libpng/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d libpng-src ]; then
	if [ ! -f "libpng-v$PNG_VERSION.tar.gz" ]; then
		wget -O libpng-v$PNG_VERSION.tar.gz https://github.com/pnggroup/libpng/archive/refs/tags/v$PNG_VERSION.tar.gz
	fi
	tar -xzf libpng-v$PNG_VERSION.tar.gz
	mv libpng-$PNG_VERSION libpng-src
fi

mkdir -p libpng-src/build
cd libpng-src/build

cmake .. -DANDROID_STL="c++_static"  \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DPNG_SHARED=OFF \
	-DPNG_TESTS=OFF \
	-DPNG_TOOLS=OFF

cmake --build . -j

# update `include` folder
rm -rf ../../../output/libpng/include
mkdir -p ../../../output/libpng/include
cp -v ../*.h ../../../output/libpng/include
cp -v pnglibconf.h ../../../output/libpng/include
# update lib
rm -rf ../../../output/libpng/lib/$TARGET_ABI/libpng.a
cp -r libpng16.a ../../../output/libpng/lib/$TARGET_ABI/libpng.a

echo "libpng build successful"
