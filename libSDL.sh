#!/bin/bash -e

SDL_VERSION=3.4.0

. ./sdk.sh

mkdir -p output/libSDL/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d libSDL-src ]; then
	wget -nc -O libsdl-$SDL_VERSION.tar.gz https://github.com/libsdl-org/SDL/archive/release-$SDL_VERSION.tar.gz
	tar -xzf libsdl-$SDL_VERSION.tar.gz
	mv SDL-release-$SDL_VERSION libSDL-src
fi

cd libSDL-src

mkdir -p build; cd build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DSDL_STATIC=ON \
	-DSDL_SHARED=OFF \
	-DSDL_AUDIO=OFF \
	-DSDL_RENDER=OFF \
	-DSDL_CAMERA=OFF \
	-DSDL_METAL=OFF \
	-DSDL_GPU=OFF \
	-DSDL_HAPTIC=OFF \
	-DSDL_POWER=OFF \
	-DSDL_DIALOG=OFF \
	-DSDL_TESTS=OFF \
	-DSDL_EXAMPLES=OFF \
	-DSDL_VULKAN=OFF \
	-DCMAKE_INSTALL_PREFIX="$(pwd)/install"

cmake --build . -j
cmake --install .

# update headers
rm -rf ../../../output/libSDL/include/
cp -r ../include ../../../output/libSDL/include
# update lib
rm -rf ../../../output/libSDL/lib/$TARGET_ABI/libSDL.a
cp libSDL3.a ../../../output/libSDL/lib/$TARGET_ABI/libSDL.a

echo "libSDL build successful"
