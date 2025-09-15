// main.s

// Goals
// 1. system call sleep
// 2. conver int to string
// 3. have fun

// The .data section is for initialized data, like our string.
.data
    .align 3
    hello_string: .string "Hello, World! " // null-terminated string
    hello_string_len = . - hello_string

    .align 3
    counter: .quad 0     // 8-byte integer initialized to 0
    numbuf:  .space 32   // enough for 20 digits + slack

// .text will contain the actual code (instructions) of the program.
.text

// main in c: 
.globl _start // _start is the entry point for the program. This is where execution begins.
_start:


loophere:

    // Sleep 500 ms = 500,000,000 ns
    movz    x0, #0x1001
    movk    x0, #0x1001, lsl #16
    movk    x0, #0x0000, lsl #32

    // x0 is the first argument to the syscall,
    // which is the number of nanoseconds to sleep.
    bl      _sleep_ns

    // Load the base address of the 'hello_string' label using adrp.
    adrp   X1, hello_string@PAGE // X1 is now the page address of hello_string. X1 is considered a base address.

    // The syscall number for write on macOS is 4, loaded into register X16.
    mov    X16, #4             // Syscall number 4 (write)
    mov    X0,  #1              // Argument 1: File descriptor 1 (stdout)
    // Add the offset to get the final address.
    add    X1, X1, hello_string@PAGEOFF
    mov    X2, hello_string_len// Argument 3: Length of the string
    svc    #0x80               // Invoke the system call

    // Load, increment, and store the counter
    adrp   X4, counter@PAGE
    add    X4, X4, counter@PAGEOFF
    ldr    X5, [X4]         // x5 = counter
    add    X5, X5, #1       // ++counter
    str    X5, [X4]

    // Convert counter (x5) to decimal string in numbuf
    adrp   X1, numbuf@PAGE
    add    X1, X1, numbuf@PAGEOFF    // x1 = buffer base
    mov    X2, #32                   // buffer size
    mov    X0, X5                    // value to convert
    bl     _u64_to_str               // returns: x0 = ptr, x1 = len

    // Write the number string
    mov    X16, #4                   // write
    mov    X2,  X1                   // len
    mov    X1,  X0                   // ptr
    mov    X0,  #1                   // stdout
    svc    #0x80

    // b is branch, loop forever
    b loophere

    // Call the exit(0) syscall.
    // The syscall number for exit on macOS is 1, loaded into register X16.
    mov    X16, #1             // Syscall number 1 (exit)
    mov    X0, #0              // Argument 1: Exit status 0
    svc    #0x80               // Invoke the system call

