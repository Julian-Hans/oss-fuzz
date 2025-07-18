#!/bin/bash

# Check if all required parameters are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <projectname> <sanitizer> <fuzzer>"
    echo "Example: $0 arrow-java address FuzzIpcFile"
    exit 1
fi

PROJECT_NAME=$1
SANITIZER=$2
FUZZER=$3

echo "Building fuzzers for project: $PROJECT_NAME"
echo "Sanitizer: $SANITIZER"
echo "Fuzzer: $FUZZER"

python infra/helper.py build_fuzzers --sanitizer $SANITIZER $PROJECT_NAME 