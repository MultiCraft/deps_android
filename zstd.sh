#!/bin/bash -e

ZSTD_VERSION=1.5.6

. sdk.sh

mkdir -p output/zstd/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d zstd-src ]; then
	git clone -b v$ZSTD_VERSION --depth 1 https://github.com/facebook/zstd.git zstd-src
	mkdir zstd-src/build/cmake/builddir
fi

cd zstd-src/build/cmake/builddir

cmake .. -DANDROID_STL="c++_static" -DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DCMAKE_BUILD_TYPE=Release \
	-DZSTD_MULTITHREAD_SUPPORT=ON \
	-DZSTD_BUILD_TESTS=OFF \
	-DZSTD_BUILD_PROGRAMS=OFF \
	-DZSTD_BUILD_STATIC=ON \
	-DZSTD_BUILD_SHARED=OFF \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_C_FLAGS_RELEASE="$CFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"

cmake --build . -j

# update `include` folder
rm -rf ../../../../../output/zstd/include/
mkdir -p ../../../../../output/zstd/include
cp -r ../../../lib/*.h ../../../../../output/zstd/include
# update lib
rm -rf ../../../../../output/zstd/lib/$TARGET_ABI/libzstd.a
cp -r ./lib/libzstd.a ../../../../../output/zstd/lib/$TARGET_ABI/libzstd.a

echo "Zstd build successful"
