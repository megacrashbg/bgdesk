#!/bin/bash

export VCPKG_TRIPLET="x64-linux"

cd /root/bgdesk

sed -i  "s/\[\"cdylib\", \"staticlib\", \"rlib\"\]/\[\"cdylib\"\]/g" Cargo.toml

pushd flutter && sed -i -e 's/extended_text: 13.0.0/extended_text: 14.0.0/g' pubspec.yaml && popd

vcpkg install --triplet $VCPKG_TRIPLET --x-install-root="$VCPKG_ROOT/installed"
# vcpkg install --triplet=x64-linux --x-install-root="$VCPKG_ROOT/installed"

# Install dependencies