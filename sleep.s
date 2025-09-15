// sleep.s

.text  // start of code section
// void sleep_ns(uint64_t ns);
// js: function _sleep_ns(ns) { ... }
// py: def _sleep_ns(ns: int) -> None: ...
// java: public static native void _sleep_ns(long ns);
.globl _sleep_ns
_sleep_ns:
    // Prologue
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    stp     x19, x20, [sp, #-16]!

    mov     x20, x0              // ns

    // kqueue()
    mov     x16, #362            // SYS_kqueue
    svc     #0x80
    mov     x19, x0              // kq

    // Convert ns -> ms (default EVFILT_TIMER units)
    // x2 = ms = ns / 1_000_000; if 0<ns<1ms, round up to 1
    movz    x1, #0x4240          // 1_000_000 = 0x0F4240
    movk    x1, #0x000F, lsl #16
    udiv    x2, x20, x1          // ms = ns / 1e6
    cbnz    x2, 1f
    cbz     x20, 1f
    mov     x2, #1               // ensure a minimum of 1ms if ns>0
1:

    // Build kevent64_s changelist (48 bytes) and eventlist (48 bytes)
    // Layout:
    //  0: ident (u64)
    //  8: filter (i16)
    // 10: flags (u16)
    // 12: fflags (u32)
    // 16: data (i64)
    // 24: udata (u64)
    // 32: ext[0] (u64)
    // 40: ext[1] (u64)
    sub     sp, sp, #96

    // changelist @ sp
    str     xzr, [sp, #0]        // ident = 0
    mov     w3, #-7              // EVFILT_TIMER
    strh    w3, [sp, #8]         // filter
    mov     w3, #0x11            // EV_ADD | EV_ONESHOT
    strh    w3, [sp, #10]        // flags
    mov     w3, #0x4             // NOTE_NSECONDS
    str     w3, [sp, #12]        // fflags
    str     x20, [sp, #16]       // data = ns
    str     xzr, [sp, #24]       // udata
    str     xzr, [sp, #32]       // ext[0]
    str     xzr, [sp, #40]       // ext[1]

    // kevent64(kq, &change, 1, &event, 1, 0, NULL)
    mov     x0, x19              // kq
    mov     x1, sp               // changelist
    mov     x2, #1               // nchanges = 1
    add     x3, sp, #48          // eventlist buffer
    mov     x4, #1               // nevents = 1
    mov     x5, xzr              // flags = 0
    mov     x6, xzr              // timeout = NULL (timer delivers event)
    mov     x16, #363            // SYS_kevent64
    svc     #0x80

    add     sp, sp, #96

    // close(kq)
    mov     x0, x19
    mov     x16, #6              // SYS_close
    svc     #0x80

    // Epilogue
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
