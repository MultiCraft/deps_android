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
		export TARGET=armv7a-linux-androideabi
		export TARGET_CPU_FAMILY=arm
		export TARGET_CPU=armv7a ;;
	"arm64")
		### toolchain config for ARM64
		export TARGET_ABI=arm64-v8a
		export TARGET_NAME=android-arm64
		export ANDROID_ABI=$TARGET_ABI
		export TARGET=aarch64-linux-android
		export TARGET_CPU_FAMILY=aarch64
		export TARGET_CPU=armv8 ;;
	"x86_64")
		### toolchain config for x86_64
		export TARGET_ABI=x86_64
		export TARGET_NAME=android-x86_64
		export ANDROID_ABI=$TARGET_ABI
		export TARGET=x86_64-linux-android
		export TARGET_CPU_FAMILY=x86_64
		export TARGET_CPU=x86_64 ;;
	*)
		echo "Don't ask to use $ARCH"
		exit 1 ;;
esac

export API=23
export CFLAGS="-Ofast -flto -fPIC -fvisibility=hidden -ffunction-sections -fdata-sections -D__ANDROID_MIN_SDK_VERSION__=$API -Wno-deprecated-ofast"
export CFLAGS_NO_FAST="-O3 -fPIC -D__ANDROID_MIN_SDK_VERSION__=$API"
export CXXFLAGS="$CFLAGS -fvisibility-inlines-hidden -fexceptions -frtti"
export NATIVE_API_LEVEL="android-$API"

echo "Configured for $TARGET_ABI"

case "$OSTYPE" in
	linux*)
		export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
		echo "Configured for Linux" ;;
	darwin*)
		export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64
		export MACOSX_DEPLOYMENT_TARGET=11.0
		echo "Configured for Mac OS" ;;
	*)
		echo "Just use right OS instead $OSTYPE"
		exit 1 ;;
esac

export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
#export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

export ANDR_ROOT=$(pwd)
export OUTPUT_PATH="$ANDR_ROOT/output"

# Convert a space-separated flag list into a Meson array literal, e.g. "['-a', '-b']"
to_meson_list() {
	local out="[" first=1 flag
	for flag in $1; do
		[ $first -eq 1 ] && first=0 || out+=", "
		out+="'$flag'"
	done
	echo "$out]"
}

# Generate a minimal pkg-config file pointing at an already-built dependency
# write_pc_file <Name> <prefix> <libname> <out_file>
write_pc_file() {
	cat > "$4" << EOF
prefix=$2
exec_prefix=\${prefix}
libdir=\${prefix}/lib/$TARGET_ABI
includedir=\${prefix}/include

Name: $1
Description:
Version: 999
Libs: -L\${libdir} -l$3
Cflags: -I\${includedir}
EOF
}

# Generate a Meson cross file for the current target
# write_meson_cross_file <out_file> <extra include flags> <extra lib dirs>
write_meson_cross_file() {
	cat > "$1" << EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
ranlib = '$RANLIB'
strip = '$STRIP'
pkg-config = 'pkg-config'

[built-in options]
c_args = $(to_meson_list "$CFLAGS $2")
c_link_args = $(to_meson_list "-flto $3")
cpp_args = $(to_meson_list "$CXXFLAGS $2")
cpp_link_args = $(to_meson_list "-flto $3")

[properties]
sys_root = '$TOOLCHAIN/sysroot'
needs_exe_wrapper = true
pkg_config_libdir = '$(pwd)/pkgconfig'

[host_machine]
system = 'android'
cpu_family = '$TARGET_CPU_FAMILY'
cpu = '$TARGET_CPU'
endian = 'little'
EOF
}
