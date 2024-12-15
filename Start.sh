#!/bin/bash -e

# List of ARCH'es
ARCHS=("armv7" "arm64" "x86_64")

for ARCH in "${ARCHS[@]}"; do
echo "Building for ARCH: $ARCH"

sed -i '' '/^arch/d' local.properties
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
if [ -w deps ]; then
	rm -rf deps
else
	echo "Cannot delete deps: Permission denied"
fi

mkdir deps
chmod -R u+w deps

# Build libs

sh gettext.sh
sh leveldb.sh
#sh luajit.sh
sh libjpeg.sh
sh libpng.sh
sh freetype.sh
sh SDL2.sh
sh irrlicht.sh
sh openal.sh
sh openssl.sh
sh libcurl.sh
sh vorbis.sh

echo "Done building for $ARCH!"
done

echo "All builds completed!"
