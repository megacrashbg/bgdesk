FROM ubuntu:18.04

WORKDIR /root
ARG DEBIAN_FRONTEND=noninteractive
ENV VCPKG_FORCE_SYSTEM_BINARIES=1
RUN apt-get update -y
RUN apt-get install --yes --no-install-recommends \
        qemu-user-static \
        g++ \
        gcc \
        git \
        curl \
        nasm \
        yasm \
        libgtk-3-dev \
        clang \
        libxcb-randr0-dev \
        libxdo-dev \
        libxfixes-dev \
        libxcb-shape0-dev \
        libxcb-xfixes0-dev \
        libasound2-dev \
        libpam0g-dev \
        libpulse-dev \
        make \
        cmake \
        wget \
        libssl-dev \
        unzip \
        zip \
        tar \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        ca-certificates \
        ninja-build \
        libclang-10-dev \
        llvm-10-dev \
        pkg-config \
        xz-utils
        

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN /root/.cargo/bin/rustup toolchain install 1.75 --target x86_64-unknown-linux-gnu --component rustfmt --profile minimal --no-self-update
RUN /root/.cargo/bin/rustup default 1.75
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

RUN apt-get install -y libva-dev 

ENV VCPKG_ROOT=/vcpkg
ENV PATH="/vcpkg:/root/flutter/bin:/root/.cargo/bin:${PATH}"
ENV VCPKG_TRIPLET="x64-linux"

# COPY ./docker/bridge.entrypoint.sh /bridge.entrypoint.sh
# RUN chmod +x /bridge.entrypoint.sh

# ENTRYPOINT ["/build-linux.entrypoint.sh"]