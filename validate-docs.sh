#!/bin/bash
# validate-docs.sh - Script to validate documentation and Mermaid diagrams

set -e  # Exit on any error

echo "Validating documentation and Mermaid diagrams..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "Error: pre-commit is not installed. Please install it with 'pip install pre-commit'."
    exit 1
fi

# Run only the specific hooks related to documentation and Mermaid
echo "Running markdownlint..."
pre-commit run markdownlint --all-files

echo "Running Mermaid validation..."
pre-commit run check-mermaid --all-files

echo "Running Markdown formatting check..."
pre-commit run mdformat --all-files

echo "All documentation checks passed!"

# Offer to help test a specific Mermaid diagram interactively
read -p "Would you like to test a specific Mermaid diagram with the live editor? (y/n): " test_specific

if [[ "$test_specific" == "y" ]]; then
    read -p "Enter the path to the Markdown file containing the diagram: " file_path
    
    if [[ -f "$file_path" ]]; then
        echo "Opening Mermaid Live Editor in your default browser..."
        echo "Copy your diagram from $file_path and paste it into the editor to test it."
        sleep 2
        if command -v xdg-open &> /dev/null; then
            xdg-open "https://mermaid.live" &> /dev/null
        elif command -v open &> /dev/null; then
            open "https://mermaid.live" &> /dev/null
        else
            echo "Please open https://mermaid.live in your browser"
        fi
    else
        echo "File not found: $file_path"
        exit 1
    fi
fi

exit 0 