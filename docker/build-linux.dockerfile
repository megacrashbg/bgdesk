FROM ubuntu:24.04

WORKDIR /root

ARG DEBIAN_FRONTEND=noninteractive
ENV VCPKG_FORCE_SYSTEM_BINARIES=1
RUN apt-get update -y
RUN apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        gpg \
        cmake \
        clang \
        curl \        
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
        llvm-14-dev \
        libclang-14-dev \
        libopus-dev \
        curl zip unzip tar

# RUN apt-get install gcc-12
# # Instalando latest CMake
# RUN apt-get remove --purge --auto-remove cmake
# RUN test -f /usr/share/doc/kitware-archive-keyring/copyright || wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
# RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null
# RUN apt-get update && apt-get install -y cmake

        
# RUN apt-get remove -y libopus-dev || true

ENV VCPKG_ROOT=/vcpkg
ENV PATH="/vcpkg:/root/flutter/bin:/root/.cargo/bin:${PATH}"
ENV VCPKG_TRIPLET="x64-linux"


# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN rustup toolchain install 1.75 --target x86_64-unknown-linux-gnu --component rustfmt --profile minimal --no-self-update
RUN rustup default 1.75
ENV CARGO_INCREMENTAL=0


# Install Flutter
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz
RUN tar -xvf flutter_linux_3.22.3-stable.tar.xz
RUN rm flutter_linux_3.22.3-stable.tar.xz

RUN git config --global --add safe.directory /root/flutter
RUN git config --global --add safe.directory /root/.cargo

RUN /root/flutter/bin/flutter --disable-analytics

# Install vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git "/vcpkg"
RUN git -C /vcpkg checkout 6f29f12e82a8293156836ad81cc9bf5af41fe836 --force
RUN chmod +x /vcpkg/bootstrap-vcpkg.sh
RUN /vcpkg/bootstrap-vcpkg.sh


RUN mkdir -p ~/.cargo/
RUN echo """ \
[source.crates-io] \
registry = 'https://github.com/rust-lang/crates.io-index' \
""" > ~/.cargo/config

WORKDIR /root/bgdesk

# RUN $VCPKG_ROOT/vcpkg install --x-install-root="$VCPKG_ROOT/installed"

# COPY ./docker/bridge.entrypoint.sh /bridge.entrypoint.sh
# RUN chmod +x /bridge.entrypoint.sh

# ENTRYPOINT ["/build-linux.entrypoint.sh"]