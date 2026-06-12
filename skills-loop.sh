#!/bin/bash

# Check if a directory path was provided as an argument
TARGET_DIR="${1:-.}"

# Ensure the targeted directory actually exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  echo "Usage: $0 [path/to/directory]"
  exit 1
fi

echo "=================================================="
echo "Starting Caterpillar scan on directory: $TARGET_DIR"
echo "=================================================="

# Loop through all markdown files in the specified directory
for file in "$TARGET_DIR"/*.md; do
  # Check if any matching markdown files actually exist
  if [ ! -e "$file" ]; then
    echo "No Markdown (.md) files found in '$TARGET_DIR'."
    exit 0
  fi

  echo ""
  echo "--------------------------------------------------"
  echo "Scanning File: $(basename "$file")"
  echo "Path: $file"
  echo "--------------------------------------------------"
  
  # Run the Caterpillar scan with the JSON flag
  caterpillar scan "$file" --json
done
