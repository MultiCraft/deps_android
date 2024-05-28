#!/bin/bash -e

# Set ARCH

export ARCH="$(grep '^arch' local.properties | sed 's/^.*=[[:space:]]*//')"

if [ -z "$ARCH" ];
then
	echo "Please specify ARCH"
	echo "e.g. \"armv7\", \"arm64\" or \"x86_64\""
	read ARCH

	if [ "$ARCH" != armv7 ] && [ "$ARCH" != arm64 ] && [ "$ARCH" != x86_64 ];
	then
		echo "$ARCH is not a valid ARCH"
		exit 1
	fi

	echo "arch = $ARCH" >> local.properties
fi

# Set NDK path
export ANDROID_NDK="$(grep '^ndk\.dir' local.properties | sed 's/^.*=[[:space:]]*//')"

if [ ! -d "$ANDROID_NDK" ];
then
	echo "Please specify path of ANDROID NDK"
	echo "e.g. $HOME/Android/android-ndk-r25"
	read ANDROID_NDK

	if [ ! -d "$ANDROID_NDK" ];
	then
		echo "$ANDROID_NDK is not a valid folder"
		exit 1
	fi

	echo "ndk.dir = $ANDROID_NDK" >> local.properties
fi

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
sh mbedtls.sh
sh libcurl.sh
sh vorbis.sh

echo "Done!"
