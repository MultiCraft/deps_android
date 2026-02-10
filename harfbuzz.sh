#!/bin/bash -e

HARFBUZZ_VERSION=12.3.2

. ./sdk.sh

mkdir -p output/harfbuzz/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d harfbuzz-src ]; then
	git clone -b $HARFBUZZ_VERSION --depth 1 https://github.com/harfbuzz/harfbuzz.git harfbuzz-src
	mkdir harfbuzz-src/build
fi

cd harfbuzz-src/build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DBUILD_SHARED_LIBS=FALSE \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_CXX_FLAGS_RELEASE="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DFREETYPE_LIBRARY="$ANDR_ROOT/output/freetype/lib/$TARGET_ABI/libfreetype.a $ANDR_ROOT/output/libpng/lib/$TARGET_ABI/libpng.a" \
	-DFREETYPE_INCLUDE_DIRS="$ANDR_ROOT/output/freetype/include" \
	-DHB_HAVE_GLIB=OFF \
	-DHB_HAVE_GOBJECT=OFF \
	-DHB_HAVE_ICU=OFF \
	-DHB_HAVE_FREETYPE=ON \
	-DHB_BUILD_SUBSET=OFF \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install"

cmake --build . -j

# update headers
rm -rf ../../../output/harfbuzz/include/
mkdir -p ../../../output/harfbuzz/include/harfbuzz
cp ../src/*.h ../../../output/harfbuzz/include/harfbuzz
# update lib
rm -rf ../../../output/harfbuzz/lib/$TARGET_ABI/libharfbuzz.a
cp libharfbuzz.a ../../../output/harfbuzz/lib/$TARGET_ABI/libharfbuzz.a

echo "Freetype build successful"
