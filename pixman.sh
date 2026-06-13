#!/bin/bash -e

. ./sdk.sh
PIXMAN_VERSION=0.46.4

mkdir -p output/pixman/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d pixman-src ]; then
	git clone -b pixman-$PIXMAN_VERSION --depth 1 https://gitlab.freedesktop.org/pixman/pixman.git pixman-src
	mkdir pixman-src/build
fi

cd pixman-src

PNG_PREFIX="$ANDR_ROOT/output/libpng"

mkdir -p pkgconfig
write_pc_file "libpng" "$PNG_PREFIX" "png" "pkgconfig/libpng.pc"
write_meson_cross_file "android-$TARGET_ABI.cross" "-I${PNG_PREFIX}/include" "-L${PNG_PREFIX}/lib/${TARGET_ABI}"

meson setup build \
	--cross-file "android-$TARGET_ABI.cross" \
	--default-library=static \
	--buildtype=release \
	-Dprefix=/ \
	-Dgtk=disabled \
	-Dtests=disabled \
	-Ddemos=disabled \
	-Dcpu-features-path="$ANDROID_NDK/sources/android/cpufeatures"

ninja -C build -j$(nproc)

# update headers
rm -rf ../../output/pixman/include
mkdir -p ../../output/pixman/include
cp pixman/*.h ../../output/pixman/include/
cp build/pixman/*.h ../../output/pixman/include/
# update lib
rm -f ../../output/pixman/lib/$TARGET_ABI/libpixman.a
cp "build/pixman/libpixman-1.a" ../../output/pixman/lib/$TARGET_ABI/libpixman.a

echo "libpixman build successful"
