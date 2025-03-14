#!/bin/bash

set -e

# Check if there are any files to process
if [ $# -eq 0 ]; then
  echo "No files provided for validation"
  exit 0
fi

# Temporary directory for extracted diagrams
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Counter for errors
ERROR_COUNT=0

echo "Checking Mermaid diagrams in markdown files..."

# Process each file
for file in "$@"; do
  # Skip non-markdown files
  if [[ ! $file =~ \.(md|markdown)$ ]]; then
    continue
  fi

  echo "Checking file: $file"

  # Extract Mermaid diagrams
  DIAGRAM_COUNT=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ $line == '```mermaid' ]]; then
      DIAGRAM_COUNT=$((DIAGRAM_COUNT + 1))
      DIAGRAM_FILE="$TEMP_DIR/diagram_${DIAGRAM_COUNT}.mmd"
      echo "" > "$DIAGRAM_FILE"

      # Read until we find the closing ```
      while IFS= read -r diagram_line || [[ -n "$diagram_line" ]]; do
        if [[ $diagram_line == '```' ]]; then
          break
        fi
        echo "$diagram_line" >> "$DIAGRAM_FILE"
      done

      # Basic validation - check for common syntax errors
      if grep -q "^graph [^A-Z]" "$DIAGRAM_FILE"; then
        echo "Error: Invalid graph direction in diagram $DIAGRAM_COUNT in $file"
        ERROR_COUNT=$((ERROR_COUNT + 1))
      elif grep -q "^flowchart [^A-Z]" "$DIAGRAM_FILE"; then
        echo "Error: Invalid flowchart direction in diagram $DIAGRAM_COUNT in $file"
        ERROR_COUNT=$((ERROR_COUNT + 1))
      else
        echo "Diagram $DIAGRAM_COUNT in $file looks valid!"
      fi
    fi
  done < "$file"

  echo "Found $DIAGRAM_COUNT diagrams in $file"
done

# Report results
echo "Mermaid validation complete."
if [ $ERROR_COUNT -gt 0 ]; then
  echo "Found $ERROR_COUNT errors. Please fix them before committing."
  exit 1
else
  echo "All diagrams are valid!"
  exit 0
fi
