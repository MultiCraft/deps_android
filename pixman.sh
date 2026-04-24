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
CROSS_FILE="android-$TARGET_ABI.cross"

mkdir -p pkgconfig

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
	'-I${PNG_PREFIX}/include']
c_link_args = ['-flto', '-fPIC', '-Wl,--gc-sections',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}']
cpp_args = ['-Ofast', '-flto', '-fPIC', '-fvisibility=hidden', '-fvisibility-inlines-hidden', '-D__ANDROID_MIN_SDK_VERSION__=$API',
	'-I${PNG_PREFIX}/include']
cpp_link_args = [
	'-flto', '-fPIC', '-Wl,--gc-sections',
	'-L${PNG_PREFIX}/lib/${TARGET_ABI}']

[properties]
sys_root = '$TOOLCHAIN/sysroot'
needs_exe_wrapper = true
pkg_config_libdir = '$ANDR_ROOT/deps/pixman-src/pkgconfig'

[host_machine]
system = 'android'
cpu_family = '$TARGET_CPU_FAMILY'
cpu = '$TARGET_CPU'
endian = 'little'
EOF

meson setup build \
	--cross-file "$CROSS_FILE" \
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
