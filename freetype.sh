#!/bin/bash -e

FREETYPE_VERSION=2.13.1

. sdk.sh

mkdir -p output/freetype/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d freetype-src ]; then
	wget https://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VERSION.tar.gz
	tar -xzvf freetype-$FREETYPE_VERSION.tar.gz
	mv freetype-$FREETYPE_VERSION freetype-src
	rm freetype-$FREETYPE_VERSION.tar.gz
	mkdir freetype-src/build
fi

cd freetype-src/build

cmake .. -DANDROID_STL="c++_static" -DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=FALSE \
	-DFT_DISABLE_BZIP2=TRUE \
	-DFT_DISABLE_PNG=TRUE \
	-DFT_DISABLE_HARFBUZZ=TRUE \
	-DFT_DISABLE_BROTLI=TRUE \
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
