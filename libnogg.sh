#!/bin/bash -e

LIBNOGG_VERSION=1.18

. ./sdk.sh

stamp_check libnogg "$LIBNOGG_VERSION" libnogg.sh && exit 0

case "$ARCH" in
	armv7|arm64) SIMD=-DENABLE_ASM_ARM_NEON ;;
	x86_64) SIMD=-DENABLE_ASM_X86_SSE2 ;;
esac

mkdir -p deps; cd deps

fetch_git libnogg-src https://github.com/achurch/libnogg "$LIBNOGG_VERSION" --depth 1

rm -rf libnogg-src/build
mkdir libnogg-src/build
cd libnogg-src/build

for src in ../src/*/*.c; do
	$CC $CFLAGS $SIMD -std=c99 -DUSE_STDIO -DVERSION=\"$LIBNOGG_VERSION\" \
		-I.. -I../include -c $src -o $(basename $(dirname $src))-$(basename $src .c).o
done

mkdir -p ../../../output/libnogg/lib/$TARGET_ABI
rm -f ../../../output/libnogg/lib/$TARGET_ABI/libnogg.a
$AR rcs ../../../output/libnogg/lib/$TARGET_ABI/libnogg.a *.o
rm -rf ../../../output/libnogg/include
cp -r ../include ../../../output/libnogg/include

echo "libnogg build successful"

stamp_write
