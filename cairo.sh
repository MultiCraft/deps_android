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
CROSS_FILE="android-$TARGET_ABI.cross"

cat > "$CROSS_FILE" << EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
ranlib = '$RANLIB'
strip = '$STRIP'
pkg-config = 'pkg-config'

[built-in options]
c_args = ['-O3', '-fPIC', '-D__ANDROID_MIN_SDK_VERSION__=$API',
	'-I${FREETYPE_PREFIX}/include', '-I${FREETYPE_PREFIX}/include/freetype2',
	'-I${PNG_PREFIX}/include',
	'-I${PIXMAN_PREFIX}/include']
c_link_args = ['-fPIC',
	'-L${FREETYPE_PREFIX}/lib/${TARGET_ABI}',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}',
	'-L${PIXMAN_PREFIX}/lib/${TARGET_ABI}']
cpp_args = ['-O3', '-fPIC', '-D__ANDROID_MIN_SDK_VERSION__=$API',
	'-I${FREETYPE_PREFIX}/include', '-I${FREETYPE_PREFIX}/include/freetype2',
	'-I${PNG_PREFIX}/include',
	'-I${PIXMAN_PREFIX}/include']
cpp_link_args = ['-fPIC',
	'-L${FREETYPE_PREFIX}/lib/${TARGET_ABI}',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}',
	'-L${PIXMAN_PREFIX}/lib/${TARGET_ABI}']
    
[properties]
sys_root = '$TOOLCHAIN/sysroot'
needs_exe_wrapper = true

[host_machine]
system = 'android'
cpu_family = '$TARGET_CPU_FAMILY'
cpu = '$TARGET_CPU'
endian = 'little'
EOF

meson setup build \
	--cross-file "$CROSS_FILE" \
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
