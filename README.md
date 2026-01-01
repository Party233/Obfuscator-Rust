# OLLVM-Rustc

This repository acts as a specialized fork of [Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator) and [Obfuscator-LLVM-16.0](https://github.com/joaovarelas/Obfuscator-LLVM-16.0), engineered to support **LLVM 21.0** and **Rust 1.92.0**.

---

## 🚀 Quick Usage

### 1. Build & Enter Docker Environment

Build the Docker image and start the container by mounting your Cargo project directory to access your code inside the container.

```bash
# Build the image
DOCKER_BUILDKIT=1 docker build -t ollvm-rustc:latest .

# Run the container (replace /path/to/cargo/proj with your actual project path)
docker run -v /path/to/cargo/proj:/projects/ -it ollvm-rustc:latest /bin/bash
```

### 2. Compile with Obfuscation

Once inside the container, you can proceed to build your project. The compiled binaries will be output to the `./target` directory.

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

> [!WARNING]
> **Performance & Stability Warning**
>
> Enabling all obfuscation features simultaneously (`-enable-allobf`) often leads to compilation failures or **Out of Memory (OOM)** errors. It is highly recommended to enable specific features individually.
>
> To mitigate memory usage, you can limit the intensity of certain passes:
> - `-indibran-max-bbs=<number>`
> - `-cffobf-max-bbs=<number>`

---

## 🛡️ Available Features

The current Rust OLLVM implementation is based on [Hikari](https://github.com/61bcdefg/Hikari-LLVM15-Core/blob/main/Obfuscation.cpp).

| Feature | Flag | Status |
| :--- | :--- | :--- |
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

## 🛠️ Development & Changelog

Recent enhancements and fixes tailored for the Rust ecosystem:

*   **Fixed:** String Encryption Pass for Rust compatibility.
*   **Fixed:** Function Wrapper for Rust compatibility.

---

## 👥 Contributors

*   [Original Contributors](https://github.com/joaovarelas/Obfuscator-LLVM-16.0)
*   [@SoulDog Research](https://github.com/SoulDog-Research)