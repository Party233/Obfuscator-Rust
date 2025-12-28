# OLLVM-Rustc-1.92.0

## This repository is a fork of [Obfuscator-LLVM](https://github.com/obfuscator-llvm/obfuscator) and [Obfuscator-LLVM-16.0](https://github.com/joaovarelas/Obfuscator-LLVM-16.0) with the goal of making it work with LLVM 21.0 and Rust 1.92.0.

## Quick Usage

Get the Docker image and run:



```bash
DOCKER_BUILDKIT=1 docker build -t ollvm-rustc-1.92.0:v0.2 .
docker run -v  /path/to/cargo/proj:/workspace/ -it ollvm-rustc-1.92.0:v0.2 /bin/bash

# target windows
cargo rustc --target x86_64-pc-windows-gnu --release --jobs 1 -- -Ccodegen-units=1 -Cdebuginfo=0 -Cstrip=symbols -Cpanic=abort -Copt-level=3 -Cllvm-args=-enable-allobf


cargo rustc --target x86_64-pc-windows-gnu --release --jobs 1 -- -Cllvm-args=-enable-allobf


# target linux
cargo rustc --target x86_64-unknown-linux-gnu --release -- -Cdebuginfo=0 -Cstrip=symbols -Cpanic=abort -Copt-level=3 -Cllvm-args=-enable-allobf
```

Compiled binaries will be placed at `./target` directory.


## Available OLLVM Features

Current Rust OLLVM is based on [Hikari](https://github.com/61bcdefg/Hikari-LLVM15-Core/blob/main/Obfuscation.cpp) which has the following features:

- (*) Anti Class Dump: `-enable-acdobf`
- (*) Anti Hooking: `-enable-antihook`
- (*) Anti Debug: `-enable-adb`
- Bogus Control Flow: `-enable-bcfobf`
- (*) Control Flow Flattening: `-enable-cffobf`
- Basic Block Splitting: `-enable-splitobf`
- Instruction Substitution: `-enable-subobf`
- Function CallSite Obf: `-enable-fco`
- String Encryption: `-enable-strcry`
- Constant Encryption: `-enable-constenc`
- Indirect Branching: `-enable-indibran`
- Function Wrapper: `-enable-funcwra`

- Enable ALL of the above: `-enable-allobf` (not going to work and you'll probably run out of memory)

- for `indibran` and `cffof`, you can use `indibran-max-bbs` or `cffobf-max-bbs` to limit the number of basic blocks in order to OOM


_* not working or not suitbale for Rust_




## Development 



## Contributors

- [@eduardo010174](https://github.com/eduardo010174)
- [@joaovarelas](https://github.com/joaovarelas)
- [@]






