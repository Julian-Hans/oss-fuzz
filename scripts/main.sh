#!/bin/bash

# Configuration - change these values as needed
PROJECT_NAME="test-cp"
SANITIZER_TYPE="address"
FUZZER_NAME="TestFuzzer"
TESTCASE_FILE="out/static_corpus/test.txt"

# Build image
build_image.sh "$PROJECT_NAME"

# Build fuzzers
build_fuzzers.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME"

# Run fuzzer
run_fuzz.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME" "$TESTCASE_FILE"
