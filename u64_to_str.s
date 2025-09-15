// u64_to_str.s

.text  // start of code section
.globl _u64_to_str
// -----------------------------------------------------------------------------
// u64 to decimal ASCII
// In:  x0 = value, x1 = buffer base, x2 = buffer size
// Out: x0 = start pointer of digits, x1 = length
// Clobbers: x3-x8
// -----------------------------------------------------------------------------
_u64_to_str:
    stp     x29, x30, [sp, -16]!
    mov     x29, sp

    add     x3, x1, x2        // x3 = end pointer (one past last)
    mov     x4, x0            // x4 = remaining value

    cbnz    x4, 1f            // if value != 0, go convert
    // value == 0 -> write '0'
    sub     x3, x3, #1
    mov     w5, #'0'
    strb    w5, [x3]
    mov     x0, x3            // start pointer
    mov     x1, #1            // length
    b       2f

1:  // Convert loop
    mov     x6, #10
0:
    udiv    x7, x4, x6        // x7 = value / 10
    msub    x8, x7, x6, x4    // x8 = value - (x7*10) = remainder
    add     w8, w8, #'0'      // ASCII digit
    sub     x3, x3, #1
    strb    w8, [x3]
    mov     x4, x7
    cbnz    x4, 0b

    // Compute length and return
    mov     x0, x3            // start pointer
    add     x1, x1, x2        // x1 = end
    sub     x1, x1, x3        // len = end - start

2:
    ldp     x29, x30, [sp], #16
    ret

