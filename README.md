# ARM64 Assembly for macOS

This repository contains ARM64 assembly code examples for macOS.

## Prerequisites

- macOS with Apple Silicon (M1/M2/M3/Ms) or ARM64 support
- Xcode Command Line Tools installed:
  ```bash
  xcode-select --install
  ```

## Files

- `hello.s` - A "Hello, World!" program written in ARM64 assembly
- `build.sh` - Build script to assemble and link ARM64 assembly files
- `hello` - Compiled executable (generated after building)

## Usage

### Building Assembly Files

Use the provided build script to compile assembly files:

```bash
./build.sh hello.s
```

This will:
1. Assemble the source file using `as`
2. Link the object file using `ld` with the System library
3. Create an executable with the same name as the source file (without extension)

### Running the Program

After building, run the executable:

```bash
./hello
```

Expected output:
```
Hello, World!
```

## How It Works

The `hello.s` file demonstrates:
- ARM64 assembly syntax for macOS
- System calls using the `svc` instruction
- Writing to stdout using the `write` syscall
- Proper program termination using the `exit` syscall

## Build Process Details

The build script performs these steps:
1. **Assemble**: `as filename.s -o filename.o` - converts assembly to object code
2. **Link**: `ld` with macOS-specific flags:
   - `-lSystem` - links against the System library
   - `-syslibroot` - specifies the SDK path
   - `-e _start` - sets the entry point
   - `-arch arm64` - targets ARM64 architecture

## Creating New Programs

To create a new assembly program:
1. Write your ARM64 assembly code in a `.s` file
2. Ensure it has a `_start` label as the entry point
3. Use `./build.sh your-file.s` to build
4. Run the resulting executable

## Notes

- This code is specifically for ARM64 macOS systems
- System call numbers and conventions are macOS-specific
- The code uses direct system calls rather than C library functions
