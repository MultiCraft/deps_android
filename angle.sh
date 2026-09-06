#!/bin/bash -e

# Chromium's ANGLE, built as libEGL.so and libGLESv2.so for one ABI.
#
# The names carry ANGLE's own suffix. Android keeps the graphics libraries in a linker
# namespace of their own and ignores an application's copy of libEGL.so or libGLESv2.so,
# so the plain names never load. The application links against the suffixed ones instead,
# which puts both its own draw calls and SDL's context on ANGLE.
#
# Chromium refuses to target Android from anything but a Linux host, which is why this
# runs in Actions rather than on a developer machine.

ABI=${1:?"pass the ABI: armeabi-v7a, arm64-v8a or x86_64"}

case "$ABI" in
	armeabi-v7a) CPU=arm ;;
	arm64-v8a)   CPU=arm64 ;;
	x86_64)      CPU=x64 ;;
	*) echo "unknown ABI $ABI" >&2; exit 1 ;;
esac

ROOT=$PWD
SRC=$ROOT/angle-src
export PATH="$ROOT/depot_tools:$PATH"
export DEPOT_TOOLS_UPDATE=0

[ -d "$ROOT/depot_tools" ] || \
	git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git "$ROOT/depot_tools"

# Self-update is off, so depot_tools never lays down its own python and the siso hook
# fails with "python3_bin_reldir.txt not found". This is what the update would have done
"$ROOT/depot_tools/ensure_bootstrap"

if [ ! -d "$SRC/.git" ]; then
	git clone --depth 1 https://chromium.googlesource.com/angle/angle "$SRC"
	( cd "$SRC" && python3 scripts/bootstrap.py )
	# The checkout has to know it is for Android before the dependencies are pulled
	grep -q target_os "$SRC/.gclient" || echo "target_os = ['android']" >> "$SRC/.gclient"
	( cd "$SRC" && gclient sync -D --no-history )
fi

cd "$SRC"

# gn rejects tab characters inside the argument string, so it is built on one line
ARGS='target_os="android" target_cpu="'"$CPU"'" is_debug=false is_component_build=false'
ARGS="$ARGS angle_libs_suffix=\"_angle\" angle_enable_vulkan=true angle_enable_gl=false"
ARGS="$ARGS angle_enable_null=false angle_enable_swiftshader=false angle_assert_always_on=false"

gn gen "out/$ABI" --args="$ARGS"

ninja -C "out/$ABI" libEGL libGLESv2

mkdir -p "$ROOT/output/angle/lib/$ABI"
cp "out/$ABI/libEGL_angle.so" "out/$ABI/libGLESv2_angle.so" "$ROOT/output/angle/lib/$ABI/"
ls -la "$ROOT/output/angle/lib/$ABI"

echo "ANGLE build successful for $ABI"
