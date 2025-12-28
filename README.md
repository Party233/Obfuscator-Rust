# OLLVM-Rustc

This repository is a fork of [Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator) and [Obfuscator-LLVM-16.0](https://github.com/joaovarelas/Obfuscator-LLVM-16.0), updated to support **LLVM 21.0** and **Rust 1.92.0**.

---

## 🚀 Quick Usage

### 1. Build & Enter Docker Environment

First, build the Docker image and start the container, mounting your cargo project directory.

```bash
# Build the image
DOCKER_BUILDKIT=1 docker build -t ollvm-rustc-1.92.0:latest .

# Run the container (replace /path/to/cargo/proj with your actual path)
docker run -v /path/to/cargo/proj:/workspace/ -it ollvm-rustc-1.92.0:latest /bin/bash

```

### 2. Compile with Obfuscation

Once inside the container, you can build your project. Compiled binaries will be placed in the `./target` directory.

**Target: Windows (GNU)**

```bash
cargo rustc --target x86_64-pc-windows-gnu --release --jobs 1 -- \
  -Ccodegen-units=1 \
  -Cdebuginfo=0 \
  -Cstrip=symbols \
  -Cpanic=abort \
  -Copt-level=3 \
  -Cllvm-args=-enable-allobf

```

**Target: Linux**

```bash
cargo rustc --target x86_64-unknown-linux-gnu --release -- \
  -Cdebuginfo=0 \
  -Cstrip=symbols \
  -Cpanic=abort \
  -Copt-level=3 \
  -Cllvm-args=-enable-allobf

```

> **⚠️ Warning on `-enable-allobf**`
> Enabling all obfuscation features simultaneously often leads to compilation failures or **Out of Memory (OOM)** errors. It is recommended to enable specific features individually.
> You can use `-indibran-max-bbs=<number>` or `-cffobf-max-bbs=<number>` to reduce the obfuscation intensity to save memory.
---

## 🛡️ Available OLLVM Features

Current Rust OLLVM is based on [Hikari](https://github.com/61bcdefg/Hikari-LLVM15-Core/blob/main/Obfuscation.cpp).

| Feature | Flag | Status |
| --- | --- | --- |
| **Bogus Control Flow** | `-enable-bcfobf` | ✅ Working |
| **Basic Block Splitting** | `-enable-splitobf` | ✅ Working |
| **Instruction Substitution** | `-enable-subobf` | ✅ Working |
| **Function CallSite Obf** | `-enable-fco` | ✅ Working |
| **String Encryption** | `-enable-strcry` | ✅ Working |
| **Constant Encryption** | `-enable-constenc` | ✅ Working |
| **Indirect Branching** | `-enable-indibran` | ✅ Working |
| **Function Wrapper** | `-enable-funcwra` | ✅ Working |
| **Control Flow Flattening** | `-enable-cffobf` | ⚠️ High Memory Cost |
| Anti Class Dump | `-enable-acdobf` | ❌ Not suitable for Rust |
| Anti Hooking | `-enable-antihook` | ❌ Not suitable for Rust |
| Anti Debug | `-enable-adb` | ❌ Not suitable for Rust |

---

## 🛠️ Development & Notes

Recent fixes and adjustments for the Rust ecosystem:

* **Fixed:** String Encryption Pass for Rust.
* **Fixed:** Function Wrapper for Rust.


---

## 👥 Contributors

* [Original Contributors](https://github.com/joaovarelas/Obfuscator-LLVM-16.0)
* [@SoulDog Research](https://github.com/SoulDog-Research)