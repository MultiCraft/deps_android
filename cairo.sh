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

mkdir -p pkgconfig

cat > pkgconfig/freetype2.pc << EOF
prefix=$ANDR_ROOT/output/freetype
exec_prefix=\${prefix}
libdir=\${prefix}/lib/$TARGET_ABI
includedir=\${prefix}/include

Name: FreeType 2
Description:
Version: 26.x
Libs: -L\${libdir} -lfreetype
Cflags: -I\${includedir}
EOF

cat > pkgconfig/pixman-1.pc << EOF
prefix=$ANDR_ROOT/output/pixman
exec_prefix=\${prefix}
libdir=\${prefix}/lib/$TARGET_ABI
includedir=\${prefix}/include

Name: Pixman
Description:
Version: 0.42.x
Libs: -L\${libdir} -lpixman
Cflags: -I\${includedir}
EOF

cat > pkgconfig/libpng.pc << EOF
prefix=$ANDR_ROOT/output/libpng
exec_prefix=\${prefix}
libdir=\${prefix}/lib/$TARGET_ABI
includedir=\${prefix}/include

Name: libpng
Description:
Version: 1.6.x
Libs: -L\${libdir} -lpng
Cflags: -I\${includedir}
EOF

cat > "$CROSS_FILE" << EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
ranlib = '$RANLIB'
strip = '$STRIP'
pkg-config = 'pkg-config'

[built-in options]
c_args = ['-Ofast', '-flto', '-fPIC', '-fvisibility=hidden', '-D__ANDROID_MIN_SDK_VERSION__=$API',
	'-I${FREETYPE_PREFIX}/include', '-I${FREETYPE_PREFIX}/include/freetype2',
	'-I${PNG_PREFIX}/include',
	'-I${PIXMAN_PREFIX}/include']
c_link_args = ['-flto', '-fPIC', '-Wl,--gc-sections',
	'-L${FREETYPE_PREFIX}/lib/${TARGET_ABI}',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}',
	'-L${PIXMAN_PREFIX}/lib/${TARGET_ABI}']
cpp_args = ['-Ofast', '-flto', '-fPIC', '-fvisibility=hidden', '-fvisibility-inlines-hidden', '-D__ANDROID_MIN_SDK_VERSION__=$API',
	'-I${FREETYPE_PREFIX}/include', '-I${FREETYPE_PREFIX}/include/freetype2',
	'-I${PNG_PREFIX}/include',
	'-I${PIXMAN_PREFIX}/include']
cpp_link_args = ['-flto', '-fPIC', '-Wl,--gc-sections',
	'-L${FREETYPE_PREFIX}/lib/${TARGET_ABI}',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}',
	'-L${PIXMAN_PREFIX}/lib/${TARGET_ABI}']

[properties]
sys_root = '$TOOLCHAIN/sysroot'
needs_exe_wrapper = true
pkg_config_libdir = '$ANDR_ROOT/deps/cairo-src/pkgconfig'

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
