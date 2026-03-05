#!/bin/sh
# Copyright (c) John Smart. Licensed under the Apache License 2.0.
# See the LICENSE file in the project root for details.
#
# build.sh — Bundle src/semver and its sourced modules into a single file
#
# Usage: bin/build.sh [-o OUTPUT]
#
# Resolves all `. "$SCRIPT_DIR/..."` source lines in src/semver and inlines
# the referenced files. The getoptions eval line is replaced with the output
# of running getoptions.sh. The result is a self-contained script.
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${PROJECT_DIR}/bin/semver"

usage() {
  printf 'Usage: %s [-o OUTPUT]\n' "$0" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage ;;
    -o) shift; OUTPUT="$1"; shift ;;
    *) usage ;;
  esac
done

VERSION_FILE="${PROJECT_DIR}/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  printf 'Error: VERSION file not found at %s\n' "$VERSION_FILE" >&2
  exit 1
fi
_version=$(cat "$VERSION_FILE" | tr -d '[:space:]')

mkdir -p "$(dirname "$OUTPUT")"

{
  _found_shebang=false
  while IFS= read -r line; do
    # Pass through the shebang
    if [ "$_found_shebang" = false ]; then
      case "$line" in
        '#!'*)
          printf '%s\n' "$line"
          _found_shebang=true
          continue
          ;;
      esac
    fi

    # Skip SCRIPT_DIR assignment — not needed in bundled script
    case "$line" in
      'SCRIPT_DIR='*) continue ;;
    esac

    # Stamp VERSION from VERSION file
    case "$line" in
      'VERSION='*)
        printf 'VERSION="%s"\n' "$_version"
        continue
        ;;
    esac

    # Inline getoptions eval
    case "$line" in
      *'eval "$(sh '*)
        printf '%s\n' "# --- getoptions (inlined) ---"
        sh "${PROJECT_DIR}/vendor/getoptions.sh" -
        printf '%s\n' "# --- end getoptions ---"
        continue
        ;;
    esac

    # Inline sourced modules
    case "$line" in
      '. "'*'/semver_'*)
        # Extract filename from `. "${SCRIPT_DIR}/semver_foo.sh"`
        _file=$(printf '%s' "$line" | sed 's|.*\(semver_[^"]*\).*|\1|')
        _path="${PROJECT_DIR}/src/${_file}"
        if [ ! -f "$_path" ]; then
          printf 'Error: %s not found\n' "$_path" >&2
          exit 1
        fi
        printf '%s\n' "# --- ${_file} (inlined) ---"
        cat "$_path"
        printf '%s\n' "# --- end ${_file} ---"
        continue
        ;;
    esac

    printf '%s\n' "$line"
  done < "${PROJECT_DIR}/src/semver"
} > "$OUTPUT"

chmod +x "$OUTPUT"
printf 'Built: %s\n' "$OUTPUT"
