#!/bin/bash -e

. ./sdk.sh
CAIRO_VERSION=1.18.4

mkdir -p output/cairo/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d cairo-src ]; then
	git clone -b $CAIRO_VERSION --depth 1 https://gitlab.freedesktop.org/cairo/cairo.git cairo-src
	mkdir cairo-src/build
fi

cd cairo-src

FREETYPE_PREFIX="$ANDR_ROOT/output/freetype"
PNG_PREFIX="$ANDR_ROOT/output/libpng"
PIXMAN_PREFIX="$ANDR_ROOT/output/pixman"

mkdir -p pkgconfig
write_pc_file "FreeType 2" "$FREETYPE_PREFIX" "freetype" "pkgconfig/freetype2.pc"
write_pc_file "Pixman" "$PIXMAN_PREFIX" "pixman" "pkgconfig/pixman-1.pc"
write_pc_file "libpng" "$PNG_PREFIX" "png" "pkgconfig/libpng.pc"

write_meson_cross_file "android-$TARGET_ABI.cross" \
	"-I${FREETYPE_PREFIX}/include -I${FREETYPE_PREFIX}/include/freetype2 -I${PNG_PREFIX}/include -I${PIXMAN_PREFIX}/include" \
	"-L${FREETYPE_PREFIX}/lib/${TARGET_ABI} -L${PNG_PREFIX}/lib/${TARGET_ABI} -L${PIXMAN_PREFIX}/lib/${TARGET_ABI}"

meson setup build \
	--cross-file "android-$TARGET_ABI.cross" \
	--wrap-mode=nodownload \
	--default-library=static \
	--buildtype=release \
	-Dprefix=/ \
	-Dfreetype=enabled \
	-Dpng=enabled \
	-Dfontconfig=disabled \
	-Dxcb=disabled \
	-Dxlib=disabled \
	-Dxlib-xcb=disabled \
	-Dzlib=disabled \
	-Dtests=disabled \
	-Dlzo=disabled \
	-Dgtk2-utils=disabled \
	-Dglib=disabled \
	-Dspectre=disabled \
	-Dsymbol-lookup=disabled \
	-Dgtk_doc=false

ninja -C build -j$(nproc)

# update headers
rm -rf ../../output/cairo/include
mkdir -p ../../output/cairo/include/cairo
cp src/*.h ../../output/cairo/include/cairo/
cp build/src/*.h ../../output/cairo/include/cairo/
# update lib
rm -f ../../output/cairo/lib/$TARGET_ABI/libcairo.a
cp build/src/libcairo.a ../../output/cairo/lib/$TARGET_ABI/libcairo.a

echo "libcairo build successful"
