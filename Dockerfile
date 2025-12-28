FROM ubuntu:24.04 as builder-llvm

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# install dependencies
RUN apt update -y &&\
    apt install --no-install-recommends -y \
    build-essential \
    cmake \
    ninja-build \
    libc6 libc6-dev \
    git \
    gcc \
    g++ \
    clang \
    perl \
    bison \
    flex \
    gperf \
    zlib1g-dev \
    libzstd-dev \
    liblzma-dev \
    libtinfo-dev \
    libxml2-dev \
    libedit-dev \
    xz-utils \
    file \
    python3 \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 \
    ca-certificates \
    curl \
    pkg-config \
    libstdc++6 \
    libssl-dev \
    protobuf-compiler

# get source code for rust-llvm, rust compiler and hikari OLLVM
WORKDIR /repos

# COPY ollvm16.patch /repos/ollvm16.patch
# COPY ollvm16.local.patch /repos/ollvm16.local.patch
COPY ollvm21.patch /repos/ollvm21.patch
#RUN git clone --single-branch --branch llvm-16.0.0rel --recursive --depth 1 https://github.com/61bcdefg/Hikari-LLVM15 ollvm-16.0
RUN git clone --single-branch --branch rustc/21.1-2025-08-01 --depth 1 https://github.com/rust-lang/llvm-project /repos/llvm-21 &&\
    cd /repos/llvm-21/ &&\
    git apply --reject --ignore-whitespace ../ollvm21.patch &&\
    test -z "$(find . -name '*.rej' -o -name '*.orig' -print -quit)"

# apply the OLLVM patch to LLVM to add obfuscation passes 
#RUN find . -name "*.rej"

WORKDIR /repos/llvm-21/
# build custom LLVM
RUN --mount=type=cache,target=/cache/llvm-build \
    cmake -G "Ninja" -S llvm -B /cache/llvm-build \
    -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS="clang;lld;" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_BUILD_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_ENABLE_BACKTRACES=OFF \
    -DLLVM_BUILD_DOCS=OFF \
    -DBUILD_SHARED_LIBS=OFF

RUN --mount=type=cache,target=/cache/llvm-build \
    cmake --build /cache/llvm-build -j$(nproc)

RUN --mount=type=cache,target=/cache/llvm-build \
    cmake --install /cache/llvm-build

FROM ubuntu:24.04 as builder-rustc

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV PATH=/opt/cargo/bin:$PATH

RUN apt update -y &&\
    apt install --no-install-recommends -y \
    build-essential \
    cmake \
    ninja-build \
    libc6 libc6-dev \
    git \
    gcc \
    g++ \
    clang \
    perl \
    bison \
    flex \
    gperf \
    zlib1g-dev \
    libzstd-dev \
    liblzma-dev \
    libtinfo-dev \
    libxml2-dev \
    libedit-dev \
    xz-utils \
    file \
    python3 \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 \
    ca-certificates \
    curl \
    pkg-config \
    libstdc++6 \
    libssl-dev \
    protobuf-compiler

# Install rustup for bootstrap
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.92.0 --profile minimal

COPY --from=builder-llvm /opt/llvm /opt/llvm

# check if llvm was built
RUN /opt/llvm/bin/llvm-config --version

RUN git clone --single-branch --branch 1.92.0 --depth 1 https://github.com/rust-lang/rust /repos/rust-1.92.0

# config rust compiler
# https://rustc-dev-guide.rust-lang.org/building/new-target.html#using-pre-built-llvm
WORKDIR /repos/rust-1.92.0/
RUN set -eux; \
    cat > bootstrap.toml <<'EOF'
change-id = "ignore"

[build]
# build/host defaults to the current machine; listed here are the targets to build (including cross targets)
target = ["x86_64-unknown-linux-gnu", "x86_64-pc-windows-gnu"]

# When using external LLVM, it is highly recommended to turn this off to avoid bootstrap still depending on in-tree llvm-project/compiler-rt
optimized-compiler-builtins = false

[rust]
debug = false
channel = "nightly"

[llvm]
# Since we use external LLVM via llvm-config, don't download/build CI LLVM
download-ci-llvm = false

[target.x86_64-unknown-linux-gnu]
llvm-config = "/opt/llvm/bin/llvm-config"
llvm-filecheck = "/opt/llvm/bin/FileCheck"
EOF

# build rust compiler
RUN --mount=type=cache,target=/repos/rust-1.92.0/build \
    --mount=type=cache,target=/opt/cargo/registry \
    --mount=type=cache,target=/opt/cargo/git \
    python3 x.py build --target x86_64-unknown-linux-gnu,x86_64-pc-windows-gnu

# build cargo
# RUN python3 x.py build tools/cargo

WORKDIR /repos/

RUN rustup toolchain install nightly-2025-10-01 --profile minimal

RUN --mount=type=cache,target=/repos/rust-1.92.0/build \
    mkdir -p /opt/rust &&\
    cp -a /repos/rust-1.92.0/build/x86_64-unknown-linux-gnu/stage1/* /opt/rust/ &&\
    cp -f /opt/rustup/toolchains/nightly-2025-10-01-x86_64-unknown-linux-gnu/bin/cargo /opt/rust/bin/cargo

WORKDIR /projects/

FROM ubuntu:24.04 as runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH=/opt/rust/bin:$PATH

RUN apt update -y &&\
    apt install --no-install-recommends -y \
    ca-certificates \
    build-essential \
    pkg-config \
    libstdc++6 \
    libgcc-s1 \
    libssl3 \
    libcurl4 \
    zlib1g \
    protobuf-compiler \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64-x86-64 &&\
    rm -rf /var/lib/apt/lists/*

COPY --from=builder-rustc /opt/rust /opt/rust

WORKDIR /projects/
