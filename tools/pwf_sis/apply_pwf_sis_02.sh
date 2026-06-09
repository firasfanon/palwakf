#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/../../patch_to_project"

if [ ! -d "$SOURCE" ]; then
  SOURCE="$(pwd)/patch_to_project"
fi

if [ ! -d "$SOURCE" ]; then
  echo "patch_to_project folder not found." >&2
  exit 1
fi

cp -R "$SOURCE"/. "$PROJECT_ROOT"/

echo "PWF-SIS-02 files copied."
echo "Next: merge integration_snippets/go_router_pwf_sis_routes_snippet.dart into the real GoRouter."
echo "Then run: dart format . && flutter analyze && flutter run -d chrome"
