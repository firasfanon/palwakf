#!/usr/bin/env bash
set -euo pipefail
stamp=$(date +%Y%m%d_%H%M%S)
archive_root="baseline_control/source_patch_archive"
mkdir -p "$archive_root"
if [ -d "source_patch" ]; then
  target="$archive_root/source_patch_$stamp"
  mv source_patch "$target"
  echo "source_patch moved to $target"
else
  echo "No source_patch directory found. Nothing to quarantine."
fi
echo "Next: dart format . ; flutter analyze"
