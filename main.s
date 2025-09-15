// main.s

// Goals
// 1. system call sleep
// 2. conver int to string
// 3. have fun

// The .data section is for initialized data, like our string.
.data
    .align 3 // align to 8 byte boundary
    // name of var  type   value
    hello_string: .string "Hello, World! " // null-terminated string
    hello_string_len = . - hello_string

.bss
    .align 3
    counter: .quad 0
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
    adrp   x4, counter@PAGE
    add    x4, x4, counter@PAGEOFF
    ldr    x5, [x4]         // x5 = counter
    add    x5, x5, #1       // ++counter
    str    x5, [x4]

    // Convert counter (x5) to decimal string in numbuf
    adrp   x1, numbuf@PAGE
    add    x1, x1, numbuf@PAGEOFF    // x1 = buffer base
    mov    x2, #32                   // buffer size
    mov    x0, x5                    // value to convert
    bl     _u64_to_str               // returns: x0 = ptr, x1 = len

    // Write the number string
    mov    x16, #4                   // write
    mov    x2,  x1                   // len
    mov    x1,  x0                   // ptr
    mov    x0,  #1                   // stdout
    svc    #0x80

    // b is branch, loop forever
    b loophere

    // Call the exit(0) syscall.
    // The syscall number for exit on macOS is 1, loaded into register X16.
    mov    X16, #1             // Syscall number 1 (exit)
    mov    X0, #0              // Argument 1: Exit status 0
    svc    #0x80               // Invoke the system call

