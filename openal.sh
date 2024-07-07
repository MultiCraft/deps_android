#!/bin/bash -e

OPENAL_VERSION=1.23.1

. sdk.sh

export SDL_PATH="$(pwd)/deps/sdl2-src/build/install/usr/local/lib/cmake/SDL2"

mkdir -p output/openal/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d openal-src ]; then
	git clone -b $OPENAL_VERSION --depth 1 https://github.com/kcat/openal-soft openal-src
fi

cd openal-src/build

cmake .. -DANDROID_STL="c++_static" \
	-DANDROID_NATIVE_API_LEVEL="$NATIVE_API_LEVEL" \
	-DANDROID_ABI="$ANDROID_ABI" \
	-DANDROID_PLATFORM="$API" \
	-DALSOFT_UTILS=NO \
	-DALSOFT_EXAMPLES=NO \
	-DALSOFT_BACKEND_OPENSL=NO \
	-DALSOFT_BACKEND_WAVE=NO \
	-DALSOFT_BACKEND_SDL2=YES \
	-DALSOFT_REQUIRE_SDL2=YES \
	-DALSOFT_EMBED_HRTF_DATA=NO \
	-DALSOFT_UPDATE_BUILD_VERSION=NO \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="$CFLAGS" \
	-DCMAKE_CXX_FLAGS="$CXXFLAGS -fPIC" \
	-DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake" \
	-DLIBTYPE=STATIC \
	-DSDL2_DIR="$SDL_PATH"

cmake --build . -j

# update `include` folder
rm -rf ../../../output/openal/include/
cp -r ../include ../../../output/openal/include
# update lib
rm -rf ../../../output/openal/lib/$TARGET_ABI/libopenal.a
cp -r libopenal.a ../../../output/openal/lib/$TARGET_ABI/libopenal.a

echo "OpenAL-Soft build successful"
