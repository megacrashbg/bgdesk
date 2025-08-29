FROM ubuntu:22.04

WORKDIR /root/bgdesk

ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.75
ENV LLVM_VERSION=15.0.6
ENV FLUTTER_VERSION=3.16.9
ENV VCPKG_COMMIT_ID=6f29f12e82a8293156836ad81cc9bf5af41fe836

# Install initial dependencies
RUN apt-get update
RUN apt-get install -y qemu-user-static curl wget git zip unzip tar

# Install Rust
ENV RUST_PATH=/root/.cargo/bin
RUN curl --proto '=https' --tlsv1.2 --retry 10 --retry-connrefused --location --silent --show-error --fail https://sh.rustup.rs | sh -s -- --default-toolchain none -y
RUN $RUST_PATH/rustup toolchain install $RUST_VERSION --target x86_64-unknown-linux-gnu --component rustfmt --profile minimal --no-self-update

ENV CARGO_INCREMENTAL=0
ENV CARGO_TERM_COLOR=always

# Install VCPKG

ENV VCPKG_ROOT=/opt/artifacts/vcpkg

RUN git clone https://github.com/microsoft/vcpkg.git -n $VCPKG_ROOT
# RUN git checkout --force $VCPKG_COMMIT_ID
# RUN chmod +x $VCPKG_ROOT/bootstrap-vcpkg.sh
# RUN $VCPKG_ROOT/bootstrap-vcpkg.sh

# RUN apt-get install -y libva-dev && apt show libva-dev



# # Install VCPKG dependencies
# RUN $VCPKG_ROOT/vcpkg install --triplet x64-linux --x-install-root="$VCPKG_ROOT/installed"

RUN apt-get install -y \
               build-essential \
               clang \
               cmake \
               curl \
               gcc \
               git \
               g++ \
               libayatana-appindicator3-dev \
               libasound2-dev \
               libgstreamer1.0-dev \
               libgstreamer-plugins-base1.0-dev \
               libgtk-3-dev \
               libpam0g-dev \
               libpulse-dev \
               libva-dev \
               libxcb-randr0-dev \
               libxcb-shape0-dev \
               libxcb-xfixes0-dev \
               libxdo-dev \
               libxfixes-dev \
               nasm \
               ninja-build \
               pkg-config \
               tree \
               python3 \
               rpm \
               unzip \
               wget \
               xz-utils \
               llvm-11-dev \
               libclang-11-dev 