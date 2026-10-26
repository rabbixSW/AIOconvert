#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' "$ROOT_DIR/pubspec.yaml")"
ARCH="$(uname -m)"
FLATPAK_BUILD_DIR="$ROOT_DIR/build/release/flatpak-build"
FLATPAK_REPO="$ROOT_DIR/build/release/flatpak-repo"
MANIFEST="$ROOT_DIR/packaging/flatpak/com.aioconvert.aioconvert.yml"
OUTPUT_DIR="$ROOT_DIR/dist"
RUNTIME_BRANCH="25.08"

if [[ -z "$VERSION" ]]; then
  printf 'Could not read the app version from pubspec.yaml.\n' >&2
  exit 1
fi

for tool in flutter flatpak-builder flatpak; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Required packaging tool "%s" was not found on PATH.\n' "$tool" >&2
    exit 1
  fi
done

cd "$ROOT_DIR"
flutter build linux --release
"$ROOT_DIR/scripts/prepare-linux-appdir.sh"
mkdir -p "$OUTPUT_DIR"

flatpak-builder \
  --force-clean \
  --install-deps-from=flathub \
  --repo="$FLATPAK_REPO" \
  "$FLATPAK_BUILD_DIR" \
  "$MANIFEST"

OUTPUT_FILE="$OUTPUT_DIR/AIOconvert-$VERSION-$ARCH.flatpak"
flatpak build-bundle \
  "$FLATPAK_REPO" \
  "$OUTPUT_FILE" \
  com.aioconvert.aioconvert \
  "$RUNTIME_BRANCH" \
  --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo

printf 'Created %s\n' "$OUTPUT_FILE"
