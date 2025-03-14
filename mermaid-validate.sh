#!/bin/bash

set -e

# Check if there are any files to process
if [ $# -eq 0 ]; then
  echo "No files provided for validation"
  exit 0
fi

# Filter for markdown files
MARKDOWN_FILES=()
for file in "$@"; do
  if [[ "$file" =~ \.(md|markdown)$ ]]; then
    MARKDOWN_FILES+=("$file")
  fi
done

# If no markdown files, exit cleanly
if [ ${#MARKDOWN_FILES[@]} -eq 0 ]; then
  echo "No markdown files to check"
  exit 0
fi

# Temporary directory for extracted diagrams
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Counter for errors
ERROR_COUNT=0
TOTAL_DIAGRAMS=0

echo "Checking Mermaid diagrams in markdown files..."

# Process each file
for file in "${MARKDOWN_FILES[@]}"; do
  echo "Checking file: $file"
  DIAGRAM_COUNT=0

  # Extract and validate Mermaid diagrams using more efficient pattern matching
  awk '/```mermaid/,/```/' "$file" | awk 'BEGIN {diagram=0; count=0; current_file=""}
  /```mermaid/ {
    count++;
    diagram=1;
    current_file=ENVIRON["TEMP_DIR"] "/diagram_" count ".mmd";
    next;
  }
  /```/ && diagram==1 {
    diagram=0;
    next;
  }
  diagram==1 {
    print $0 > current_file;
  }
  END {
    print count;
  }' TEMP_DIR="$TEMP_DIR"

  # Count diagrams in the current file
  DIAGRAM_COUNT=$(find "$TEMP_DIR" -name "diagram_*.mmd" | wc -l)
  TOTAL_DIAGRAMS=$((TOTAL_DIAGRAMS + DIAGRAM_COUNT))

  # Validate each diagram
  for diagram_file in "$TEMP_DIR"/diagram_*.mmd; do
    if [[ ! -f "$diagram_file" ]]; then
      continue
    fi

    DIAGRAM_NUM=$(basename "$diagram_file" | sed 's/diagram_\(.*\)\.mmd/\1/')

    # More comprehensive validation checks
    if grep -q "^graph [^A-Z]" "$diagram_file"; then
      echo "Error: Invalid graph direction in diagram $DIAGRAM_NUM in $file"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    elif grep -q "^flowchart [^A-Z]" "$diagram_file"; then
      echo "Error: Invalid flowchart direction in diagram $DIAGRAM_NUM in $file"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    elif grep -q "^sequenceDiagram" "$diagram_file" && ! grep -q "participant" "$diagram_file"; then
      echo "Warning: Sequence diagram $DIAGRAM_NUM in $file has no participants"
    else
      echo "Diagram $DIAGRAM_NUM in $file looks valid!"
    fi

    # Clean up this diagram file
    rm "$diagram_file"
  done

  echo "Found $DIAGRAM_COUNT diagrams in $file"
done

# Report results
echo "Mermaid validation complete. Checked $TOTAL_DIAGRAMS diagrams."
if [ $ERROR_COUNT -gt 0 ]; then
  echo "Found $ERROR_COUNT errors. Please fix them before committing."
  exit 1
else
  echo "All diagrams are valid!"
  exit 0
fi
