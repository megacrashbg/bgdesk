#!/bin/bash

OS=$(uname -s)
ARCH=$(uname -m)

MAC="Darwin"
WINDOWS="NT"
LINUX="Linux"

rm -rf build
mkdir -p build

FORCED_PLATFORM=$1

ANDROID_NDK_HOME=/Users/belizario/Library/Android/sdk/ndk/27.2.12479018

buildWindows()
{
    pushd flutter && sed -i -e 's/extended_text: 13.0.0/extended_text: 14.0.0/g' pubspec.yaml && flutter pub get && popd
    # python build.py --portable --hwcodec --flutter --skip-portable-pack --vram
    python build.py --portable --flutter
    rm -rf build/windows

    mkdir -p build/windows
    mv flutter/build/windows/x64/runner/Release/* build/windows/
    mv build/windows/rustdesk.exe build/windows/bgdesk.exe
    ./sign.sh build/windows/bgdesk.exe
}

buildMac()
{
    pushd flutter && sed -i -e 's/extended_text: 14.0.0/extended_text: 13.0.0/g' pubspec.yaml && flutter pub get && popd
    ./build.py --flutter --hwcodec --unix-file-copy-paste
    mv flutter/build/macos/Build/Products/Release/BGDesk.app ./build/BGDesk.app
    cd build
    zip -vr bgdesk-$BUILD_PATH-darwin.zip BGDesk.app
    cd ..
}

buildLinux()
{
    echo "Building Linux"
    docker build -t bgdesk-build -f docker/build-linux.dockerfile .
    docker run -it -v $(pwd):/root/bgdesk bgdesk-build
}

buildAndroid()
{
    TARGET=aarch64-linux-android
    echo "Building Android"
    ./flutter/ndk_arm64.sh
    mkdir -p ./flutter/android/app/src/main/jniLibs/arm64-v8a
    cp ./target/aarch64-linux-android/release/liblibrustdesk.so ./flutter/android/app/src/main/jniLibs/arm64-v8a/librustdesk.so

    # temporary use debug sign config
    sed -i "s/signingConfigs.release/signingConfigs.debug/g" ./flutter/android/app/build.gradle


    mkdir -p ./flutter/android/app/src/main/jniLibs/arm64-v8a
    cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ./flutter/android/app/src/main/jniLibs/arm64-v8a/
    cp ./target/$TARGET/release/liblibrustdesk.so ./flutter/android/app/src/main/jniLibs/arm64-v8a/librustdesk.so
    # build flutter
    pushd flutter
    flutter build apk "--release" --target-platform android-arm64 --split-per-abi
    mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ../bgdesk.apk


    popd
    mkdir -p signed-apk; pushd signed-apk
    mv ../bgdesk.apk .
}

if [[ $FORCED_PLATFORM == "windows" ]]; then
   buildWindows
   exit 0
fi
if [[ $FORCED_PLATFORM == "mac" ]]; then
   buildMac
   exit 0
fi
if [[ $FORCED_PLATFORM == "linux" ]]; then
   buildLinux
   exit 0
fi
if [[ $FORCED_PLATFORM == "android" ]]; then
   buildAndroid
   exit 0
fi

if [[ $OS == *$WINDOWS* ]]; then
   buildWindows
   exit 0
fi

if [[ $OS == *$MAC* ]]; then
   buildMac
   exit 0
fi


if [[ $OS == *$LINUX* ]]; then
   buildLinux
fi