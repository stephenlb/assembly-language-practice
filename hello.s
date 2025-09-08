// Standard ARM64 macOS assembly for Hello World.

// The .data section is for initialized data, like our string.
.data
hello_string:
    .ascii "Hello, World!\n"
    hello_string_len = . - hello_string

// The .text section contains the executable code.
.text

// .globl makes the _start symbol globally visible, so the linker can find it.
.globl _start

// .p2align 2 aligns the code to a 4-byte boundary.
.p2align 2

_start:
    // Call the write(1, hello_string, hello_string_len) syscall.
    // The syscall number for write on macOS is 4, loaded into register X16.
    mov    X16, #4             // Syscall number 4 (write)
    mov    X0, #1              // Argument 1: File descriptor 1 (stdout)

    // Load the base address of the 'hello_string' label using adrp.
    adrp   X1, hello_string@PAGE

    // Add the offset to get the final address.
    add    X1, X1, hello_string@PAGEOFF

    mov    X2, hello_string_len// Argument 3: Length of the string
    svc    #0x80               // Invoke the system call

    // Call the exit(0) syscall.
    // The syscall number for exit on macOS is 1, loaded into register X16.
    mov    X16, #1             // Syscall number 1 (exit)
    mov    X0, #0              // Argument 1: Exit status 0
    svc    #0x80               // Invoke the system call
