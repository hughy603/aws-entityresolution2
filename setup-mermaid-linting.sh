#!/bin/bash

# Setup script for Mermaid diagram linting
# This script installs and configures the necessary dependencies for Mermaid diagram validation

set -e

echo "Setting up Mermaid diagram linting..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js 14 or higher."
    exit 1
fi

# Check/install mermaid-cli
if ! command -v mmdc &> /dev/null; then
    echo "Installing @mermaid-js/mermaid-cli..."
    npm install -g @mermaid-js/mermaid-cli
else
    echo "mermaid-cli is already installed."
fi

# Check/install pre-commit
if ! command -v pre-commit &> /dev/null; then
    echo "Installing pre-commit..."
    pip install pre-commit
else
    echo "pre-commit is already installed."
fi

# Install pre-commit hooks
echo "Installing pre-commit hooks..."
pre-commit install

# Make validation scripts executable
chmod +x validate-mermaid.sh
chmod +x test/test-mermaid-validation.sh

echo "Running a test validation..."
./test/test-mermaid-validation.sh

echo "============================================="
echo "Mermaid diagram linting setup is complete!"
echo "============================================="
echo ""
echo "You can now create and commit Markdown files with Mermaid diagrams."
echo "All diagrams will be automatically validated before each commit."
echo ""
echo "For manual validation, run:"
echo "  ./validate-mermaid.sh your-markdown-file.md"
echo ""
echo "For more information, see README-mermaid-linting.md" 