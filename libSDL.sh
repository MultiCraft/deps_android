#!/bin/bash -e

SDL_VERSION=3.4.10-RPC

. ./sdk.sh

mkdir -p output/libSDL/lib/$TARGET_ABI
mkdir -p deps; cd deps

fetch_git libSDL-src https://github.com/MoNTE48/SDL "$SDL_VERSION" --depth 1

cd libSDL-src

# Android keeps the graphics libraries in a linker namespace of its own and ignores an
# application's libEGL.so, so ANGLE ships under its own names. SDL opens EGL by a name
# compiled into it, and that name has to be ANGLE's for the context and the draw calls
# to end up in the same implementation
if [ "${SDL_ANGLE:-0}" = "1" ]; then
	sed -i \
		-e 's/"libEGL\.so"/"libEGL_angle.so"/g' \
		-e 's/"libGLESv2\.so"/"libGLESv2_angle.so"/g' \
		src/video/SDL_egl.c
	grep -n "libEGL_angle\|libGLESv2_angle" src/video/SDL_egl.c
fi

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
	-DSDL_AVX=OFF \
	-DSDL_AVX2=OFF \
	-DSDL_AVX512F=OFF \
	-DSDL_AUDIO=OFF \
	-DSDL_RENDER=OFF \
	-DSDL_CAMERA=OFF \
	-DSDL_METAL=OFF \
	-DSDL_GPU=OFF \
	-DSDL_HAPTIC=OFF \
	-DSDL_HIDAPI=OFF \
	-DSDL_POWER=OFF \
	-DSDL_DIALOG=OFF \
	-DSDL_TESTS=OFF \
	-DSDL_TRAY=OFF \
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
