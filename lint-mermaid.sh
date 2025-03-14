#!/bin/bash

# Lint Mermaid Diagrams using industry-standard tools
# This script runs Mermaid diagram linting on all markdown files in the project

echo "Setting up environment..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "pre-commit is not installed. Installing..."
    pip install pre-commit
else
    echo "pre-commit is already installed."
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js 14 or higher."
    exit 1
fi

# Check if mermaid-cli is installed
if ! command -v mmdc &> /dev/null; then
    echo "Installing @mermaid-js/mermaid-cli..."
    npm install -g @mermaid-js/mermaid-cli
else
    echo "mermaid-cli is already installed."
fi

echo "Running pre-commit Mermaid hooks..."
pre-commit run check-mermaid --all-files

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✅ All Mermaid diagrams are valid!"
else
    echo "❌ Some Mermaid diagrams have errors. Please fix them before committing."
fi

echo "Running additional validation with mermaid-cli..."
find . -type f -name "*.md" -o -name "*.markdown" | xargs grep -l '```mermaid' | while read -r file; do
    echo "Validating Mermaid diagrams in $file"
    TEMP_FILE=$(mktemp)
    # Extract each Mermaid diagram and validate it
    grep -n -A 1000 '```mermaid' "$file" | grep -B 1000 -m 1 '```' | grep -v '```' > "$TEMP_FILE" || true
    if [ -s "$TEMP_FILE" ]; then
        echo "Running mermaid-cli validation..."
        mmdc --input "$TEMP_FILE" --validate || exit_code=1
    fi
    rm "$TEMP_FILE"
done

echo "Checking for formatting consistency..."
pre-commit run mdformat --all-files

exit $exit_code 