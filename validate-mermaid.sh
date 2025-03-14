#!/bin/bash

# Mermaid Diagram Validator
# This script extracts and validates Mermaid diagrams from Markdown files
# It requires @mermaid-js/mermaid-cli to be installed (npm install -g @mermaid-js/mermaid-cli)

set -e

# Check if mermaid-cli is installed
if ! command -v mmdc &> /dev/null; then
    echo "Error: @mermaid-js/mermaid-cli is not installed."
    echo "Please install it using: npm install -g @mermaid-js/mermaid-cli"
    exit 1
fi

EXIT_CODE=0
TEMP_DIR=$(mktemp -d)

# Clean up temporary directory on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Function to extract and validate Mermaid diagrams
validate_diagrams() {
    local file="$1"
    local diagram_count=0
    local error_count=0
    
    echo "Validating Mermaid diagrams in: $file"
    
    # Use awk to extract Mermaid diagrams
    awk '
    BEGIN { in_mermaid = 0; diagram_num = 0; }
    /^```mermaid$/ { 
        in_mermaid = 1; 
        diagram_num++; 
        diagram_file = "'"$TEMP_DIR"'/diagram_" diagram_num ".mmd"; 
        start_line = NR;
        next; 
    }
    /^```$/ && in_mermaid { 
        in_mermaid = 0; 
        close(diagram_file);
        print start_line ":" diagram_file;
        next; 
    }
    in_mermaid { print $0 > diagram_file; }
    ' "$file" > "$TEMP_DIR/diagram_map.txt"
    
    # Process each diagram
    while IFS=: read -r start_line diagram_file; do
        if [ -s "$diagram_file" ]; then
            diagram_count=$((diagram_count + 1))
            
            if ! mmdc --validate --input "$diagram_file" 2>/dev/null; then
                echo "Error in diagram at line $start_line in $file"
                echo "Diagram content:"
                echo "---------------"
                cat "$diagram_file"
                echo "---------------"
                error_count=$((error_count + 1))
                EXIT_CODE=1
            fi
        fi
    done < "$TEMP_DIR/diagram_map.txt"
    
    if [ $diagram_count -eq 0 ]; then
        echo "No Mermaid diagrams found in $file"
    elif [ $error_count -eq 0 ]; then
        echo "✅ All $diagram_count diagrams in $file are valid"
    else
        echo "❌ Found $error_count errors in $diagram_count diagrams in $file"
    fi
}

# Process all provided files
for file in "$@"; do
    if [ -f "$file" ]; then
        validate_diagrams "$file"
    fi
done

exit $EXIT_CODE 