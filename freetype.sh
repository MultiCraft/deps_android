#!/bin/bash -e

FREETYPE_VERSION=2.13.2

. sdk.sh

mkdir -p output/freetype/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d freetype-src ]; then
	wget https://sourceforge.net/projects/freetype/files/freetype2/$FREETYPE_VERSION/freetype-$FREETYPE_VERSION.tar.gz
	tar -xzf freetype-$FREETYPE_VERSION.tar.gz
	mv freetype-$FREETYPE_VERSION freetype-src
	rm freetype-$FREETYPE_VERSION.tar.gz
	mkdir freetype-src/build
fi

cd freetype-src/build

cmake .. -DANDROID_STL="c++_static" -DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=FALSE \
	-DFT_DISABLE_BZIP2=TRUE \
	-DFT_DISABLE_HARFBUZZ=TRUE \
	-DFT_DISABLE_BROTLI=TRUE \
	-DFT_REQUIRE_PNG=TRUE \
	-DFT_REQUIRE_ZLIB=TRUE \
	-DPNG_LIBRARY="$ANDR_ROOT/output/libpng/lib/$TARGET_ABI/libpng.a" \
	-DPNG_PNG_INCLUDE_DIR="$ANDR_ROOT/output/libpng/include" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"

cmake --build . -j

# update `include` folder
rm -rf ../../../output/freetype/include/
cp -r ../include ../../../output/freetype/include
rm -rf ../../../output/freetype/include/dlg
# update lib
rm -rf ../../../output/freetype/lib/$TARGET_ABI/libfreetype.a
cp -r libfreetype.a ../../../output/freetype/lib/$TARGET_ABI/libfreetype.a

echo "Freetype build successful"
