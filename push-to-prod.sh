#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="/Users/jd/Library/CloudStorage/ProtonDrive-jd@levier.cc-folder/coding/misc/vivaldi-css"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

echo "Syncing:"
echo "  from: $SOURCE_DIR"
echo "    to: $TARGET_DIR"

rsync -a --delete \
  --exclude ".git/" \
  --exclude ".DS_Store" \
  "$SOURCE_DIR/" "$TARGET_DIR/"

echo "Done."
