#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' "$ROOT_DIR/pubspec.yaml")"
ARCH="$(uname -m)"
APPDIR="$ROOT_DIR/build/release/AppDir"
OUTPUT_DIR="$ROOT_DIR/dist"
LINUXDEPLOY="${LINUXDEPLOY:-linuxdeploy}"

if [[ -z "$VERSION" ]]; then
  printf 'Could not read the app version from pubspec.yaml.\n' >&2
  exit 1
fi

command -v flutter >/dev/null 2>&1 || {
  printf 'Flutter was not found on PATH.\n' >&2
  exit 1
}
command -v "$LINUXDEPLOY" >/dev/null 2>&1 || [[ -x "$LINUXDEPLOY" ]] || {
  printf 'linuxdeploy was not found. Install it or set LINUXDEPLOY to its path.\n' >&2
  exit 1
}

cd "$ROOT_DIR"
flutter build linux --release
"$ROOT_DIR/scripts/prepare-linux-appdir.sh"
mkdir -p "$OUTPUT_DIR"

export LINUXDEPLOY_OUTPUT_APP_NAME=AIOconvert
export LINUXDEPLOY_OUTPUT_VERSION="$VERSION"
export LDAI_OUTPUT="$OUTPUT_DIR/AIOconvert-$VERSION-$ARCH.AppImage"
"$LINUXDEPLOY" --appdir "$APPDIR" --output appimage

printf 'Created %s\n' "$LDAI_OUTPUT"
