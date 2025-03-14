#!/bin/bash

# Test script for Mermaid diagram validation
# This will test both valid and invalid diagrams to ensure our validation works

set -e

echo "== Testing Mermaid diagram validation =="

# Ensure dependencies are installed
if ! command -v mmdc &> /dev/null; then
    echo "Installing @mermaid-js/mermaid-cli..."
    npm install -g @mermaid-js/mermaid-cli
fi

# Make validation script executable
chmod +x validate-mermaid.sh

echo "Testing valid diagram..."
./validate-mermaid.sh test/mermaid/valid-diagram.md
VALID_RESULT=$?

if [ $VALID_RESULT -eq 0 ]; then
    echo "✅ Valid diagram test passed"
else
    echo "❌ Valid diagram test failed"
    exit 1
fi

echo "Testing invalid diagram..."
./validate-mermaid.sh test/mermaid/invalid-diagram.md
INVALID_RESULT=$?

if [ $INVALID_RESULT -ne 0 ]; then
    echo "✅ Invalid diagram test passed (validation correctly failed)"
else
    echo "❌ Invalid diagram test failed (validation incorrectly passed)"
    exit 1
fi

echo "== All tests passed =="
exit 0
