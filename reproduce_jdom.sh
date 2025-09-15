#!/bin/bash

set -e

PROJECT="jdom"
COMMIT="c6065f68"
PAYLOAD_FILE="reproducer_payload/clusterfuzz-testcase-minimized-SAXBuilderFuzzer-5420846446149632"
FUZZER="SAXBuilderFuzzer"

echo "Building jdom at commit $COMMIT..."

# Build the base image
#python infra/helper.py build_image $PROJECT

# Build fuzzers with specific commit using environment variable
#python infra/helper.py build_fuzzers $PROJECT -e CHECKOUT_COMMIT=$COMMIT

echo "Running reproducer with payload..."

# Run the reproducer with the payload
python infra/helper.py reproduce $PROJECT $FUZZER $PAYLOAD_FILE

echo "Done!"