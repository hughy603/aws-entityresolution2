#!/bin/bash

# Test script for Mermaid linter
# This script creates test files with valid and invalid Mermaid diagrams
# and runs the linter to verify it works correctly

set -e

# Create test directory
mkdir -p test/mermaid
echo "Creating test files..."

# Create test file with valid diagram
cat > test/mermaid/valid-diagram.md << 'EOF'
# Valid Mermaid Diagram Test

This file contains a valid Mermaid diagram.

```mermaid
flowchart LR
    A[Start] --> B{Is it valid?}
    B -->|Yes| C[Success]
    B -->|No| D[Failure]
    C --> E[End]
    D --> E
```
EOF

# Create test file with invalid diagram
cat > test/mermaid/invalid-diagram.md << 'EOF'
# Invalid Mermaid Diagram Test

This file contains an invalid Mermaid diagram.

```mermaid
flowchart LR
    A[Start] --> B{Is it valid?}
    B ->|Yes| C[Success]  <!-- Missing an arrow character -->
    B -->|No| D[Failure]
    C -> E[End]  <!-- Missing an arrow character -->
    D --> 
```
EOF

# Print test setup
echo "Created test files:"
echo " - test/mermaid/valid-diagram.md (contains a valid diagram)"
echo " - test/mermaid/invalid-diagram.md (contains an invalid diagram)"
echo

# Test valid diagram
echo "Testing valid diagram..."
node mermaid-lint.js test/mermaid/valid-diagram.md
if [ $? -eq 0 ]; then
    echo "✅ Valid diagram test passed"
else
    echo "❌ Valid diagram test failed"
    exit 1
fi

# Test invalid diagram (should fail)
echo
echo "Testing invalid diagram (should report errors)..."
if node mermaid-lint.js test/mermaid/invalid-diagram.md; then
    echo "❌ Invalid diagram test failed - linter did not detect errors"
    exit 1
else
    echo "✅ Invalid diagram test passed - linter correctly detected errors"
fi

echo
echo "All tests completed successfully!"
echo "The mermaid linter is working as expected" 