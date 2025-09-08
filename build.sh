#!/bin/bash
echo "Building $1"

# Check for input
if [ -z "$1" ]; then
  echo "Usage: $0 <source-file.s>"
  exit 1
fi

# Remove extension if present
filename=$(basename -- "$1")
name="${filename%.*}"
echo "Filename: $filename"
echo "Name: $name"

## Build
as $filename -o $name.o
ld -o $name $name.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64
