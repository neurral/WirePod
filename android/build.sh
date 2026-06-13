#!/bin/bash

set -e

WP_COMMIT_HASH=$(cd ../wire-pod && git rev-parse --short HEAD)
GOLDFLAGS="-X 'github.com/kercre123/wire-pod/chipper/pkg/vars.CommitSHA=${WP_COMMIT_HASH}' -checklinkname=0"


if [[ ${GHACTIONS} == "" ]]; then
    if [[ -z "${ANDROID_HOME}" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            export ANDROID_HOME=$HOME/Library/Android/sdk
        else
            export ANDROID_HOME=$HOME/Android/Sdk
        fi
    fi

    if [[ -z "${ANDROID_NDK_HOME}" ]]; then
        if [[ -d "${ANDROID_HOME}/ndk-bundle" ]]; then
            export ANDROID_NDK_HOME="${ANDROID_HOME}/ndk-bundle"
        else
            # Find the latest NDK directory in ndk/
            NDK_DIRS=($(ls -d "${ANDROID_HOME}/ndk"/* 2>/dev/null | sort -V))
            if [ ${#NDK_DIRS[@]} -gt 0 ]; then
                NDK_INDEX=$(( ${#NDK_DIRS[@]} - 1 ))
                if [ -d "${NDK_DIRS[NDK_INDEX]}" ]; then
                    export ANDROID_NDK_HOME="${NDK_DIRS[NDK_INDEX]}"
                fi
            fi
        fi
    fi

    if [[ -z "${ANDROID_NDK_HOME}" ]]; then
        echo "Could not find Android NDK under ndk-bundle or ndk/ directory in ${ANDROID_HOME}."
        echo "You must install the Android NDK via Android Studio SDK Manager."
        exit 1
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        HOST_OS="darwin-x86_64"
    else
        HOST_OS="linux-x86_64"
    fi
    export TCHAIN=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_OS}/bin

    if [[ -z "${APKSIGNER}" ]]; then
        if [[ -f "${ANDROID_HOME}/build-tools/34.0.0/apksigner" ]]; then
            export APKSIGNER="${ANDROID_HOME}/build-tools/34.0.0/apksigner"
        else
            # Find the latest build-tools directory
            BUILD_TOOLS_DIRS=($(ls -d "${ANDROID_HOME}/build-tools"/* 2>/dev/null | sort -V))
            if [ ${#BUILD_TOOLS_DIRS[@]} -gt 0 ]; then
                BT_INDEX=$(( ${#BUILD_TOOLS_DIRS[@]} - 1 ))
                if [ -d "${BUILD_TOOLS_DIRS[BT_INDEX]}" ]; then
                    export APKSIGNER="${BUILD_TOOLS_DIRS[BT_INDEX]}/apksigner"
                fi
            fi
        fi
    fi
elif [[ ${GHACTIONS} == "true" ]]; then
    export ANDROID_HOME="$(pwd)/android-ndk"
    export TCHAIN=${ANDROID_HOME}/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin
    export APKSIGNER="$(pwd)/android-14/apksigner"
fi

if [[ ! $1 ]]; then
	echo "You must provide a verison (./build.sh 1.0.0)"
	exit 1
fi
ORIGVERSION=$1
VERSION=${1#v}
if [[ $1 == "main" ]]; then
    ORIGVERSION=v1.0.0
    VERSION=1.0.0
fi
if [[ ! -d $TCHAIN ]]; then
    echo "Couldn't find $TCHAIN"
    echo "You must install the Android SDK and an ndk-bundle."
    exit 1
fi

# Dynamically update prefix in pkgconfig files for the current absolute path
perl -pi -e "s|^prefix=.*|prefix=$(pwd)/built-libs/arm64|g" "$(pwd)/built-libs/arm64/lib/pkgconfig/opus.pc" 2>/dev/null || true
perl -pi -e "s|^prefix=.*|prefix=$(pwd)/built-libs/arm64|g" "$(pwd)/built-libs/arm64/lib/pkgconfig/ogg.pc" 2>/dev/null || true
perl -pi -e "s|^prefix=.*|prefix=$(pwd)/built-libs/armv7|g" "$(pwd)/built-libs/armv7/lib/pkgconfig/opus.pc" 2>/dev/null || true
perl -pi -e "s|^prefix=.*|prefix=$(pwd)/built-libs/armv7|g" "$(pwd)/built-libs/armv7/lib/pkgconfig/ogg.pc" 2>/dev/null || true
if [[ ! -f $HOME/go/bin/fyne ]]; then
    echo "Couldn't find fyne"
    if [[ ${GHACTIONS} == "true" ]]; then
        go install fyne.io/tools/cmd/fyne@latest
    else
        echo 'This can be installed with "go install fyne.io/tools/cmd/fyne@latest"'
        exit 1
    fi
fi
if [[ ! -f key/ks.jks ]]; then
    echo "Signing keystore not found"
    echo "Generate a key with keytool. There must be a keystore at ./key/ks.jks and a password for that at ./key/passwd"
    echo 'Ex: "keytool -genkey -v -keystore your-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your-alias"'
    exit 1
fi
if [[ ! -f key/passwd ]]; then
    echo "Signing keystore not found"
    echo "Generate a key with keytool. There must be a keystore at ./key/ks.jks and a password for that at ./key/passwd"
    echo 'Ex: "keytool -genkey -v -keystore your-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias your-alias"'
    exit 1
fi
echo "Zipping static files and bundling..."
cd resources
rm -rf webroot intent-data epod pod-bot-install.sh weather-map.json
cp -r ../../wire-pod/chipper/webroot .
cp -r ../../wire-pod/chipper/intent-data .
cp -r ../../wire-pod/chipper/epod .
cp -r ../../wire-pod/vector-cloud/pod-bot-install.sh .
cp -r ../../wire-pod/chipper/weather-map.json .
cp -r ../../wire-pod/chipper/stttest.pcm .
echo $ORIGVERSION > version
zip -r static.zip .
cd ..
rm -f static.go
$HOME/go/bin/fyne bundle -o static.go resources/static.zip
# Find any available arm64 clang compiler or fall back to generic clang with target
ARM64_CLANG_PATH=$(ls ${TCHAIN}/aarch64-linux-android*-clang 2>/dev/null | sort -V | head -n 1)
if [[ -n "${ARM64_CLANG_PATH}" ]]; then
    export CC="${ARM64_CLANG_PATH}"
    export CXX="${ARM64_CLANG_PATH}++"
    export CGO_LDFLAGS="-L$(pwd)/built-libs/arm64/lib"
    export CGO_CFLAGS="-I$(pwd)/built-libs/arm64/include"
else
    export CC="${TCHAIN}/clang"
    export CXX="${TCHAIN}/clang++"
    export CGO_CFLAGS="-target aarch64-linux-android23 -I$(pwd)/built-libs/arm64/include"
    export CGO_LDFLAGS="-target aarch64-linux-android23 -L$(pwd)/built-libs/arm64/lib"
fi
export CGO_ENABLED=1
export PKG_CONFIG_PATH="$(pwd)/built-libs/arm64/lib/pkgconfig"
echo "Building vessel APK..."
cd vessel
GOOS=android GOARCH=arm64 $HOME/go/bin/fyne package -os android/arm64 -appID com.kercre123.wirepod -icon ../icons/png/podfull.png --name WirePod --tags nolibopusfile --appVersion $VERSION
cp WirePod.apk ../
cd ..
echo "Building WirePod for android/arm64..."
GOOS=android GOARCH=arm64 go build -buildmode=c-shared -ldflags="-s -w ${GOLDFLAGS}" -o libWirePod-arm64.so -tags nolibopusfile
# Find any available armv7 clang compiler or fall back to generic clang with target
ARMV7_CLANG_PATH=$(ls ${TCHAIN}/armv7a-linux-androideabi*-clang 2>/dev/null | sort -V | head -n 1)
if [[ -n "${ARMV7_CLANG_PATH}" ]]; then
    export CC="${ARMV7_CLANG_PATH}"
    export CXX="${ARMV7_CLANG_PATH}++"
    export CGO_LDFLAGS="-L$(pwd)/built-libs/armv7/lib"
    export CGO_CFLAGS="-I$(pwd)/built-libs/armv7/include"
else
    export CC="${TCHAIN}/clang"
    export CXX="${TCHAIN}/clang++"
    export CGO_CFLAGS="-target armv7a-linux-androideabi21 -I$(pwd)/built-libs/armv7/include"
    export CGO_LDFLAGS="-target armv7a-linux-androideabi21 -L$(pwd)/built-libs/armv7/lib"
fi
export CGO_ENABLED=1
export PKG_CONFIG_PATH="$(pwd)/built-libs/armv7/lib/pkgconfig"
echo "Building WirePod for android/arm (GOARM=7)..."
#GOARCH=arm GOARM=7 GOOS=android $HOME/go/bin/fyne build --os android -o libWirePod-armv7.so -tags nolibopusfile
GOOS=android GOARCH=arm GOARM=7 go build -buildmode=c-shared -ldflags="-s -w ${GOLDFLAGS}" -o libWirePod-armv7.so -tags nolibopusfile
echo "Putting libraries in vessel APK..."
rm -rf tmp
mkdir -p tmp
cd tmp
cp ../WirePod.apk .
mkdir -p lib/arm64-v8a
mkdir -p lib/armeabi-v7a
cp ../built-libs/arm64/lib/libopus.so lib/arm64-v8a/
cp ../built-libs/arm64/lib/libvosk.so lib/arm64-v8a/
cp ../built-libs/armv7/lib/libopus.so lib/armeabi-v7a/
cp ../built-libs/armv7/lib/libvosk.so lib/armeabi-v7a/
cp ../libWirePod-armv7.so lib/armeabi-v7a/libWirePod.so
cp ../libWirePod-arm64.so lib/arm64-v8a/libWirePod.so
zip -r WirePod.apk lib
${APKSIGNER} sign --ks ../key/ks.jks --ks-pass pass:"$(cat ../key/passwd)" --out ../WirePod.apk WirePod.apk
cd ..
rm -rf tmp
rm -f libWirePod-armv7.so
rm -f libWirePod-arm64.so
rm -f WirePod.apk.idsig
rm -f vessel/WirePod.apk
rm -f resources/static.zip
rm -f static.go
# Clean up temporary resources and local git modifications
if [[ ${GHACTIONS} == "" ]]; then
    echo "Cleaning up local git modifications..."
    (cd .. && git checkout -- android/built-libs/arm64/lib/pkgconfig/*.pc android/built-libs/armv7/lib/pkgconfig/*.pc android/resources/ 2>/dev/null || true)
fi

mv WirePod.apk WirePod-$VERSION.apk
echo "Build complete ./WirePod-$VERSION.apk"
