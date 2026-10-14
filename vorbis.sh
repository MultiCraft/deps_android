#!/bin/bash -e

VORBIS_REPO=https://github.com/MoNTE48/libvorbis-android

. ./sdk.sh

stamp_check vorbis "$(git_head "$VORBIS_REPO")" vorbis.sh && exit 0

mkdir -p output/vorbis/lib/$TARGET_ABI
mkdir -p deps; cd deps

fetch_git vorbis-src "$VORBIS_REPO" "" --depth 1

cd vorbis-src

$ANDROID_NDK/ndk-build -j \
	APP_ABI="$TARGET_ABI" \
	APP_PLATFORM=android-"$API" \
	APP_CFLAGS="$CFLAGS"

# update headers
rm -rf ../../output/vorbis/include/
cp -r jni/include ../../output/vorbis/include
# update lib
rm -rf ../../output/vorbis/lib/$TARGET_ABI/libvorbis.a
cp obj/local/$TARGET_ABI/libvorbis.a ../../output/vorbis/lib/$TARGET_ABI/libvorbis.a

echo "Vorbis build successful"

stamp_write
