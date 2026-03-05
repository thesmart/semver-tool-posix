#!/bin/sh
# Copyright (c) John Smart. Licensed under the Apache License 2.0.
# https://github.com/thesmart/semver-tool-posix
#
# Install semver-tool-posix from GitHub.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/thesmart/semver-tool-posix/main/bin/install.sh | sh
#   curl -fsSL ... | sh -s -- --prefix /opt
#   curl -fsSL ... | sh -s -- --help
#
# PREFIX defaults to /usr/local (the standard location for locally-installed
# software on Unix-like systems per the Filesystem Hierarchy Standard).
# The binary is placed in $PREFIX/bin/semver.
set -eu

REPO="thesmart/semver-tool-posix"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
PREFIX="/usr/local"

usage() {
  printf 'Usage: curl -fsSL <url>/bin/install.sh | sh [-s -- OPTIONS]\n\n' >&2
  printf 'Options:\n' >&2
  printf '  --prefix DIR   Install prefix (default: /usr/local)\n' >&2
  printf '  --help         Print this help message\n' >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage ;;
    --prefix) shift; PREFIX="$1"; shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage ;;
  esac
done

BINDIR="${PREFIX}/bin"
DEST="${BINDIR}/semver"

# Require curl or wget
if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -qO- "$1"; }
else
  printf 'Error: curl or wget is required\n' >&2
  exit 1
fi

# Portable temp file (POSIX does not guarantee mktemp)
TMPFILE="${TMPDIR:-/tmp}/semver-install.$$"
trap 'rm -f "$TMPFILE"' EXIT

printf 'Downloading semver to %s ...\n' "$DEST"
fetch "${BASE_URL}/bin/semver" > "$TMPFILE"

# Verify we got a shell script, not an error page
_first_line=$(head -n 1 "$TMPFILE")
case "$_first_line" in
  '#!'*) ;;
  *)
    printf 'Error: downloaded file does not look like a shell script\n' >&2
    exit 1
    ;;
esac

# Elevate with sudo only when needed
run_privileged() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif command -v doas >/dev/null 2>&1; then
    doas "$@"
  else
    printf 'Error: cannot write to %s and neither sudo nor doas is available\n' "$BINDIR" >&2
    exit 1
  fi
}

if [ ! -d "$BINDIR" ]; then
  mkdir -p "$BINDIR" 2>/dev/null || {
    printf 'Creating %s requires elevated privileges.\n' "$BINDIR"
    run_privileged mkdir -p "$BINDIR"
  }
fi

if [ -w "$BINDIR" ]; then
  install -m 0755 "$TMPFILE" "$DEST"
else
  printf 'Installing to %s requires elevated privileges.\n' "$BINDIR"
  run_privileged install -m 0755 "$TMPFILE" "$DEST"
fi

printf 'Installed %s\n' "$("$DEST" --version)"
