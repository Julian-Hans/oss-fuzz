#!/bin/bash

# Configuration - change these values as needed
PROJECT_NAME="apache-commons-compress"
SANITIZER_TYPE="address"
FUZZER_NAME="CompressorLZ4Fuzzer"
TESTCASE_FILE="out/static_corpus/test.txt"

# Build image
#./scripts/build_image.sh "$PROJECT_NAME"

# Build fuzzers
#./scripts/build_fuzzers.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME"

# Run fuzzer
./scripts/run_fuzz.sh "$PROJECT_NAME" "$SANITIZER_TYPE" "$FUZZER_NAME" "$TESTCASE_FILE"
