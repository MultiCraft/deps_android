#!/bin/bash -e

NGHTTP2_VERSION=1.68.0

. ./sdk.sh

mkdir -p output/nghttp2/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d nghttp2-src ]; then
	wget -nc -O nghttp2-$NGHTTP2_VERSION.tar.gz https://github.com/nghttp2/nghttp2/archive/v$NGHTTP2_VERSION.tar.gz
	tar -xzf nghttp2-$NGHTTP2_VERSION.tar.gz
	mv nghttp2-$NGHTTP2_VERSION nghttp2-src
fi

cd nghttp2-src

mkdir -p build; cd build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DBUILD_SHARED_LIBS=0 \
	-DBUILD_STATIC_LIBS=1 \
	-DENABLE_APP=0 \
	-DENABLE_HPACK_TOOLS=0 \
	-DENABLE_EXAMPLES=0 \
	-DENABLE_FAILMALLOC=0 \
	-DENABLE_LIB_ONLY=1 \
	-DENABLE_DOC=0 \
	-DBUILD_TESTING=0

cmake --build . -j

# update headers
rm -rf ../../../output/nghttp2/include/
mkdir -p ../../../output/nghttp2/include/nghttp2
cp -r ../lib/includes/nghttp2/*.h ../../../output/nghttp2/include/nghttp2
cp -r lib/includes/nghttp2/*.h ../../../output/nghttp2/include/nghttp2
# update lib
rm -rf ../../../output/nghttp2/lib/$TARGET_ABI/libnghttp2.a
cp lib/libnghttp2.a ../../../output/nghttp2/lib/$TARGET_ABI/libnghttp2.a

echo "nghttp2 build successful"
