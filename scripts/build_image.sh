#!/bin/bash

# Check if required parameter is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <projectname>"
    echo "Example: $0 arrow-java"
    exit 1
fi

PROJECT_NAME=$1

echo "Building image for project: $PROJECT_NAME"

python infra/helper.py build_image $PROJECT_NAME 