#!/bin/bash

ROOT_PATH=$(dirname $(realpath $0))

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
    pushd flutter && sed -i.bak 's/extended_text: 13.0.0/extended_text: 14.0.0/g' pubspec.yaml && flutter pub get && popd
    # python build.py --portable --hwcodec --flutter --skip-portable-pack --vram
    python build.py --portable --flutter
    rm -rf build/windows

    mkdir -p build/windows
    mv -f flutter/build/windows/x64/runner/Release/* build/windows/
    mv -f build/windows/rustdesk.exe build/windows/bgdesk.exe
    ./sign.sh build/windows/bgdesk.exe
}

buildMac()
{
   pushd flutter && sed -i.bak 's/extended_text: 13.0.0/extended_text: 14.0.0/g' pubspec.yaml && popd

   echo "Building Mac Cliente"

   rm -rf build/BGDesk.app
   rm -rf flutter/build/macos/Build/Products/Release/BGDesk.app   
   
   cd libs/hbb_common/src && sed -i.bak 's/.map_or(false, |x| x == ("incoming"))/.map_or(true, |x| x == ("incoming"))/g' config.rs && cd $ROOT_PATH
   ./build.py --flutter --hwcodec --unix-file-copy-paste
   cd libs/hbb_common/src && sed -i.bak 's/.map_or(true, |x| x == ("incoming"))/.map_or(false, |x| x == ("incoming"))/g' config.rs && cd $ROOT_PATH

   mv -f flutter/build/macos/Build/Products/Release/BGDesk.app ./build/BGDesk.app
   cd build 
   zip -yr bgdesk-cliente-darwin.zip BGDesk.app
   cd ..
   mv -f build/bgdesk-cliente-darwin.zip ../dist/


   
   echo "Building Mac Suporte"

   rm -rf build/BGDesk.app
   rm -rf flutter/build/macos/Build/Products/Release/BGDesk.app

   ./build.py --flutter --hwcodec --unix-file-copy-paste
   mv -f flutter/build/macos/Build/Products/Release/BGDesk.app ./build/BGDesk.app
   cd build && zip -yr bgdesk-suporte-darwin.zip BGDesk.app && rm -rf BGDesk.app && cd ..  
   mv -f build/bgdesk-suporte-darwin.zip ../dist/

}

buildLinux_x86_64()
{
    echo "Building Linux-x86_64"
    docker build --platform="linux/amd64" -t bgdesk-build-x86_64 -f docker/build-linux.dockerfile .
    docker run --platform="linux/amd64" -it -v $(pwd):/root/bgdesk bgdesk-build-x86_64
}

buildLinux_aarch64()
{
    echo "Building Linux-aarch64"
    docker --platform="linux/arm64" build -t bgdesk-build-aarch64 -f docker/build-linux.dockerfile .
    docker --platform="linux/arm64" run -it -v $(pwd):/root/bgdesk bgdesk-build-aarch64
}

buildAndroid()
{
    TARGET=aarch64-linux-android
    echo "Building Android"
    ./flutter/ndk_arm64.sh
    mkdir -p ./flutter/android/app/src/main/jniLibs/arm64-v8a
    cp ./target/aarch64-linux-android/release/liblibrustdesk.so ./flutter/android/app/src/main/jniLibs/arm64-v8a/librustdesk.so

    # temporary use debug sign config
    sed -i.bak "s/signingConfigs.release/signingConfigs.debug/g" ./flutter/android/app/build.gradle


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
if [[ $FORCED_PLATFORM == "linux-x86_64" ]]; then
   buildLinux_x86_64
   exit 0
fi
if [[ $FORCED_PLATFORM == "linux-aarch64" ]]; then
   buildLinux_aarch64
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


if [[ $OS == *$LINUX* && $ARCH == 'x86_64' ]]; then
   buildLinux_x86_64
   exit 0
fi