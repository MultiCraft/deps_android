#!/bin/bash -e

SDL_VERSION=3.2.8

. ./sdk.sh

mkdir -p output/sdl3/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d sdl3-src ]; then
    if [ ! -f "release-$SDL_VERSION.tar.gz" ]; then
	   wget https://github.com/libsdl-org/SDL/archive/release-$SDL_VERSION.tar.gz
    fi
	tar -xzf release-$SDL_VERSION.tar.gz
	mv SDL-release-$SDL_VERSION sdl3-src
fi

cd sdl3-src

mkdir -p build; cd build

cmake .. -DANDROID_STL="c++_static" \
    -DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
    -DANDROID_ABI="$ANDROID_ABI" \
    -DANDROID_PLATFORM="$API" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
    -DSDL_STATIC=1 \
    -DSDL_SHARED=0

cmake --build . -j

DESTDIR="$(pwd)/install" cmake --install .

# update `include` folder
rm -rf ../../../output/sdl3/include/
cp -r ../include ../../../output/sdl3/include
# update lib
rm -rf ../../../output/sdl3/lib/$TARGET_ABI/libSDL3.a
cp -r libSDL3.a ../../../output/sdl3/lib/$TARGET_ABI/libSDL3.a

echo "libSDL build successful"
