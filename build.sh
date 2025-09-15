#!/bin/bash

as main.s -o main.o
as sleep.s -o sleep.o
as u64_to_str.s -o u64_to_str.o
ld -o main -lSystem \
    -syslibroot `xcrun -sdk macosx --show-sdk-path` \
    -e _start \
    -arch arm64 \
    u64_to_str.o \
    sleep.o \
    main.o
