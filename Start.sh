#!/bin/bash -e

# List of ARCH'es
ARCHS=("armv7" "arm64" "x86_64")

for ARCH in "${ARCHS[@]}"; do
echo "Building for ARCH: $ARCH"

case "$OSTYPE" in
	darwin*)
	sed -i '' '/^arch/d' local.properties
	;;
	*)
	touch local.properties
	sed -i '/^arch/d' local.properties
	;;
esac
echo "arch = $ARCH" >> local.properties

# Set NDK path
export ANDROID_NDK="$(grep '^ndk\.dir' local.properties | sed 's/^.*=[[:space:]]*//')"

if [ ! -d "$ANDROID_NDK" ];
then
	echo "Please specify path of ANDROID NDK"
	echo "e.g. $HOME/Android/android-ndk-r26"
	read ANDROID_NDK

	if [ ! -d "$ANDROID_NDK" ];
	then
		echo "$ANDROID_NDK is not a valid folder"
		exit 1
	fi

	echo "ndk.dir = $ANDROID_NDK" >> local.properties
fi

# Clean the deps
mkdir -p deps
chmod -R u+w deps
find deps -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

# Build libs

./gettext.sh
./leveldb.sh
if [[ "$OSTYPE" == linux* ]]; then
	./luajit.sh
fi
./libjpeg.sh
./libpng.sh
./freetype.sh
./libSDL.sh
./openssl.sh
./irrlicht.sh
./openal.sh
./libcurl.sh
./vorbis.sh
./zstd.sh

echo "Done building for $ARCH!"
done

echo "All builds completed!"
