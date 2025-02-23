#!/bin/bash -e

ZSTD_VERSION=1.5.7

. sdk.sh

mkdir -p output/zstd/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d zstd-src ]; then
	if [ ! -f "zstd-v$ZSTD_VERSION.tar.gz" ]; then
		wget -O zstd-v$ZSTD_VERSION.tar.gz https://github.com/facebook/zstd/archive/refs/tags/v$ZSTD_VERSION.tar.gz
	fi
	tar -xzf zstd-v$ZSTD_VERSION.tar.gz
	mv zstd-$ZSTD_VERSION zstd-src
fi

mkdir -p zstd-src/build/cmake/builddir
cd zstd-src/build/cmake/builddir

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DZSTD_MULTITHREAD_SUPPORT=OFF \
	-DZSTD_BUILD_TESTS=OFF \
	-DZSTD_BUILD_PROGRAMS=OFF \
	-DZSTD_BUILD_STATIC=ON \
	-DZSTD_BUILD_SHARED=OFF

cmake --build . -j

# update `include` folder
rm -rf ../../../../../output/zstd/include/
mkdir -p ../../../../../output/zstd/include
cp -r ../../../lib/*.h ../../../../../output/zstd/include
# update lib
rm -rf ../../../../../output/zstd/lib/$TARGET_ABI/libzstd.a
cp -r ./lib/libzstd.a ../../../../../output/zstd/lib/$TARGET_ABI/libzstd.a

echo "Zstd build successful"
