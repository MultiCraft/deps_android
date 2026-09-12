#!/bin/bash -e

OBOE_VERSION=1.10.0

. ./sdk.sh

mkdir -p output/oboe/lib/$TARGET_ABI
mkdir -p deps; cd deps

fetch_git oboe-src https://github.com/google/oboe "$OBOE_VERSION" --depth 1
mkdir -p oboe-src/build

cd oboe-src/build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DBUILD_SHARED_LIBS=NO \
	-DOBOE_UNIT_TESTS=NO \
	-DOBOE_DISABLE_CONVERSION=YES \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build . -j

# update headers
rm -rf ../../../output/oboe/include/
cp -r ../include ../../../output/oboe/include
# update lib
rm -rf ../../../output/oboe/lib/$TARGET_ABI/liboboe.a
cp liboboe.a ../../../output/oboe/lib/$TARGET_ABI/liboboe.a

echo "Oboe build successful"
