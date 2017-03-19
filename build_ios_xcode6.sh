#!/bin/sh

set -xe


CURRENTPATH=`pwd`

mkdir -p "${CURRENTPATH}/src"
cd "${CURRENTPATH}/"

DEST="${CURRENTPATH}/lib-ios"
mkdir -p "${DEST}"

ARCHS="armv7 arm64 x86_64 i386"

LIBS="libplist.a"

for arch in $ARCHS; do
	case $arch in
		arm*)

		IOSV="-miphoneos-version-min=7.0"
		echo "Building for iOS $arch ****************"
		
		SDKROOT="$(xcrun --sdk iphoneos --show-sdk-path)"
		CC="$(xcrun --sdk iphoneos -f clang)"
		CXX="$(xcrun --sdk iphoneos -f clang++)"
		CPP="$(xcrun -sdk iphonesimulator -f clang++)"
		CFLAGS="-isysroot $SDKROOT -arch $arch $IOSV -isystem $SDKROOT/usr/include -fembed-bitcode"
		CXXFLAGS=$CFLAGS
		CPPFLAGS=$CFLAGS
		export CC CXX CFLAGS CXXFLAGS CPPFLAGS
		./autogen.sh --prefix=$DEST --without-cython --host=arm-apple-darwin
		;;

		*)
		IOSV="-mios-simulator-version-min=7.0"
		echo "Building for iOS $arch*****************"

		SDKROOT="$(xcrun --sdk iphonesimulator --show-sdk-path)"
		CC="$(xcrun -sdk iphoneos -f clang)"
		CXX="$(xcrun -sdk iphonesimulator -f clang++)"
		CPP="$(xcrun -sdk iphonesimulator -f clang++)"
		CFLAGS="-isysroot $SDKROOT -arch $arch $IOSV -isystem $SDKROOT/usr/include -fembed-bitcode"
		CXXFLAGS=$CFLAGS
		CPPFLAGS=$CFLAGS
		export CC CXX CFLAGS CXXFLAGS CPPFLAGS
		./autogen.sh --prefix=$DEST --without-cython --host=$arch
		;;

	esac
	make > /dev/null
	make install
	make clean
	for i in $LIBS; do
		mv $DEST/lib/$i $DEST/lib/$i.$arch
	done
done

for i in $LIBS; do
	input=""
	for arch in $ARCHS; do
		input="$input $DEST/lib/$i.$arch"
	done
	lipo -create -output $DEST/lib/$i $input
done