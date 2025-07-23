#!/bin/bash

# Check if all required parameters are provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <projectname> <sanitizer> <fuzzer> <testcase_file>"
    echo "Example: $0 arrow-java address FuzzIpcFile /path/to/my_test_input.txt"
    exit 1
fi

PROJECT_NAME=$1
SANITIZER=$2
FUZZER=$3
TESTCASE_FILE=$4

echo "Running fuzzer for project: $PROJECT_NAME"
echo "Sanitizer: $SANITIZER"
echo "Fuzzer: $FUZZER"
echo "Testcase file: $TESTCASE_FILE"

# Check if testcase file exists
if [ ! -f "$TESTCASE_FILE" ]; then
    echo "Error: Testcase file '$TESTCASE_FILE' does not exist"
    exit 1
fi

# Run fuzzer with reproduce command
python3 infra/helper.py reproduce \
  "$PROJECT_NAME" \
  "$FUZZER" \
  "$TESTCASE_FILE" \
  -- \
  -runs=2
