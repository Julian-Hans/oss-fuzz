#!/bin/bash

# Configuration - change these values as needed
PROJECT_NAME="test-cp"
SANITIZER_TYPE="address"
FUZZER_NAME="TestFuzzer"
TESTCASE_FILE="/Users/julian.hans/repos/PoV-Agent-Oss-Fuzz/test-cases/test.txt"

# Build image
./scripts/build_image.sh "$PROJECT_NAME"

# Build fuzzers
./scripts/build_fuzzers.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME"

# Run fuzzer
./scripts/run_fuzz.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME" "$TESTCASE_FILE"
