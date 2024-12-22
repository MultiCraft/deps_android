#!/bin/bash -e

LEVELDB_VERSION=1.23

. ./sdk.sh

mkdir -p output/leveldb/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d leveldb-src ]; then
	git clone -b $LEVELDB_VERSION --depth 1 https://github.com/google/leveldb leveldb-src
	mkdir leveldb-src/build
fi

cd leveldb-src/build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DBUILD_SHARED_LIBS=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DLEVELDB_BUILD_TESTS=OFF \
	-DLEVELDB_BUILD_BENCHMARKS=OFF \
	-DLEVELDB_INSTALL=OFF

cmake --build . -j

# update `include` folder
rm -rf ../../../output/leveldb/include/
cp -r ../include ../../../output/leveldb/include
# update lib
rm -rf ../../../output/leveldb/lib/$TARGET_ABI/libleveldb.a
cp -r libleveldb.a ../../../output/leveldb/lib/$TARGET_ABI/libleveldb.a

echo "LevelDB build successful"
