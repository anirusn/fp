#!/bin/bash

# Run Trivy
# echo "Running Trivy..."
# trivy --exit-code 1 --severity HIGH --no-progress .

# Run TFLint
echo "Running TFLint..."
tflint

