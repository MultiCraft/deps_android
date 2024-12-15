#!/bin/bash -e

export ARCH="$(grep '^arch' local.properties | sed 's/^.*=[[:space:]]*//')"

if [ -z "$ARCH" ];
then
	echo "Please specify ARCH using Start.sh"
	exit 1
fi

export ANDROID_NDK="$(grep '^ndk\.dir' local.properties | sed 's/^.*=[[:space:]]*//')"

if [ ! -d "$ANDROID_NDK" ];
then
	echo "Please specify NDK path using Start.sh"
	exit 1
fi

case "$ARCH" in
	"armv7")
		### toolchain config for ARMv7
		export TARGET_ABI=armeabi-v7a
		export TARGET_NAME=android-arm
		export ANDROID_ABI="$TARGET_ABI with NEON"
		export TARGET=armv7a-linux-androideabi ;;
	"arm64")
		### toolchain config for ARM64
		export TARGET_ABI=arm64-v8a
		export TARGET_NAME=android-arm64
		export ANDROID_ABI=$TARGET_ABI
		export TARGET=aarch64-linux-android ;;
	"x86_64")
		### toolchain config for x86_64
		export TARGET_ABI=x86_64
		export TARGET_NAME=android-x86_64
		export ANDROID_ABI=$TARGET_ABI
		export TARGET=x86_64-linux-android ;;
	*)
		echo "Don't ask to use $ARCH"
		exit 1 ;;
esac

export API=23
export CFLAGS="-fvisibility=hidden -fvisibility-inlines-hidden -fexceptions -D__ANDROID_MIN_SDK_VERSION__=$API"
export CXXFLAGS="$CFLAGS -frtti"
export NATIVE_API_LEVEL="android-$API"

echo "Configured for $TARGET_ABI"

case "$OSTYPE" in
	linux*)
		export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
		echo "Configured for Linux" ;;
	darwin*)
		export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64
		export MACOSX_DEPLOYMENT_TARGET=10.15
		echo "Configured for Mac OS" ;;
	*)
		echo "Just use right OS instead $OSTYPE"
		exit 1 ;;
esac

export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

export ANDR_ROOT=$(pwd)
export OUTPUT_PATH="$ANDR_ROOT/output"
