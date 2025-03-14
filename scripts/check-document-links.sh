#!/bin/bash

set -e

# Directory containing markdown files
DOCS_DIR="docs"
ERROR_COUNT=0
WARNING_COUNT=0
TOTAL_FILES=0
TOTAL_LINKS=0

if [ ! -d "$DOCS_DIR" ]; then
  echo "Error: Documentation directory '$DOCS_DIR' not found!"
  exit 1
fi

echo "Checking internal document links..."

# Find all markdown files
MARKDOWN_FILES=$(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null)

if [ -z "$MARKDOWN_FILES" ]; then
  echo "No markdown files found in $DOCS_DIR"
  exit 0
fi

# Function to check if a file exists
check_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  return 0
}

# Check if a link is an external URL
is_external_url() {
  local link="$1"
  if [[ "$link" =~ ^https?:// ]]; then
    return 0  # It's an external URL
  fi
  return 1  # Not an external URL
}

# Check all markdown files for broken links
for file in $MARKDOWN_FILES; do
  TOTAL_FILES=$((TOTAL_FILES + 1))
  echo "Checking links in: $file"

  # Extract all internal markdown links
  # Format: [text](link.md) or [text](directory/link.md)
  LINKS=$(grep -o -E '\[.*?\]\([^)]*\.md[^)]*\)' "$file" 2>/dev/null | sed -E 's/\[.*\]\(([^)]*)\)/\1/g' | sed 's/#.*$//')

  # If no links found, continue to next file
  if [ -z "$LINKS" ]; then
    echo "  No internal links found in $file"
    continue
  fi

  # Process each link
  link_count=0
  for link in $LINKS; do
    link_count=$((link_count + 1))
    TOTAL_LINKS=$((TOTAL_LINKS + 1))

    # Skip external URLs
    if is_external_url "$link"; then
      echo "  Skipping external URL: $link"
      continue
    fi

    # Remove any fragment identifiers (#section)
    link_file="${link%%#*}"

    # Check if the link is absolute or relative
    if [[ "$link_file" == /* ]]; then
      # Absolute link (starts with /)
      target_file=".$link_file"
    else
      # Relative link
      target_file="$(dirname "$file")/$link_file"
    fi

    # Normalize path
    target_file=$(realpath --relative-to="$(pwd)" "$target_file" 2>/dev/null || echo "$target_file")

    # Check if the file exists
    if ! check_file_exists "$target_file"; then
      echo "  ERROR: Broken link in $file: $link -> $target_file (file not found)"
      ERROR_COUNT=$((ERROR_COUNT + 1))
    else
      # If the link has a fragment identifier, check if the section exists
      if [[ "$link" == *#* ]]; then
        section="${link#*#}"
        # Simple check for section headers
        if ! grep -q "^#.*$section" "$target_file" 2>/dev/null && ! grep -q "id=\"$section\"" "$target_file" 2>/dev/null; then
          echo "  WARNING: Section may not exist in $file: $link -> $target_file#$section"
          WARNING_COUNT=$((WARNING_COUNT + 1))
        fi
      fi
    fi
  done

  echo "  Found $link_count links in $file"
done

# Report results
echo ""
echo "Link validation complete:"
echo "- Checked $TOTAL_FILES files with $TOTAL_LINKS links total"
echo "- Found $ERROR_COUNT errors and $WARNING_COUNT warnings"

if [ $ERROR_COUNT -gt 0 ]; then
  echo "Please fix broken links before committing."
  exit 1
elif [ $WARNING_COUNT -gt 0 ]; then
  echo "Review sections that might not exist (warnings), but proceeding."
  exit 0
else
  echo "All document links are valid!"
  exit 0
fi
