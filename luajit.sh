#!/bin/bash -e

LUAJIT_VERSION=2.1

. ./sdk.sh

mkdir -p output/luajit/lib/$TARGET_ABI
mkdir -p deps; cd deps

if [ ! -d luajit-src ]; then
	wget -nc -O luajit-$LUAJIT_VERSION.tar.gz https://github.com/LuaJIT/LuaJIT/archive/v$LUAJIT_VERSION.tar.gz
	tar -xzf luajit-$LUAJIT_VERSION.tar.gz
	mv LuaJIT-$LUAJIT_VERSION luajit-src
fi

cd luajit-src

if [ $TARGET_ABI == armeabi-v7a ];
then
	HOST_CC="clang -m32"
else
	HOST_CC="clang -m64"
fi

CFLAGS=$CFLAGS_NO_FAST
make amalg -j \
	HOST_CC="$HOST_CC" \
	TARGET_SYS=Linux \
	CC="$CC" \
	TARGET_AR="$AR rcus" \
	TARGET_STRIP="$STRIP" \
	BUILDMODE=static

# update `src` folder
rm -rf ../../output/luajit/include
mkdir -p ../../output/luajit/include
cp src/*.h ../../output/luajit/include/
# update lib
rm -rf ../../output/luajit/lib/$TARGET_ABI/libluajit.a
cp src/libluajit.a ../../output/luajit/lib/$TARGET_ABI/libluajit.a

echo "LuaJIT build successful"
