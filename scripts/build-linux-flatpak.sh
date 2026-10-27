#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' "$ROOT_DIR/pubspec.yaml")"
ARCH="$(uname -m)"
FLATPAK_BUILD_DIR="$ROOT_DIR/build/release/flatpak-build"
FLATPAK_REPO="$ROOT_DIR/build/release/flatpak-repo"
FLATPAK_FILES="$ROOT_DIR/build/release/flatpak-files"
FFMPEG_DIR="$ROOT_DIR/build/release/flatpak-ffmpeg"
FFMPEG_ARCHIVE_NAME="ffmpeg-master-latest-linux64-gpl-shared.tar.xz"
FFMPEG_ARCHIVE="$FFMPEG_DIR/$FFMPEG_ARCHIVE_NAME"
FFMPEG_CHECKSUMS="$FFMPEG_DIR/checksums.sha256"
FFMPEG_EXTRACT_DIR="$FFMPEG_DIR/extracted"
FFMPEG_DOWNLOAD_BASE="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest"
MANIFEST="$ROOT_DIR/packaging/flatpak/com.aioconvert.aioconvert.yml"
OUTPUT_DIR="$ROOT_DIR/dist"
APP_BRANCH="stable"

if [[ -z "$VERSION" ]]; then
  printf 'Could not read the app version from pubspec.yaml.\n' >&2
  exit 1
fi

for tool in flutter flatpak-builder flatpak curl sha256sum tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Required packaging tool "%s" was not found on PATH.\n' "$tool" >&2
    exit 1
  fi
done

if [[ "$ARCH" != "x86_64" ]]; then
  printf 'The Linux FFmpegKit bundle currently supports x86_64 only; found %s.\n' "$ARCH" >&2
  exit 1
fi

cd "$ROOT_DIR"
flutter build linux --release
mkdir -p "$FFMPEG_DIR"
curl -fsSL "$FFMPEG_DOWNLOAD_BASE/checksums.sha256" -o "$FFMPEG_CHECKSUMS"
EXPECTED_FFMPEG_HASH="$(
  awk -v filename="$FFMPEG_ARCHIVE_NAME" '$2 == filename { print $1; exit }' \
    "$FFMPEG_CHECKSUMS"
)"
if [[ ! "$EXPECTED_FFMPEG_HASH" =~ ^[[:xdigit:]]{64}$ ]]; then
  printf 'No valid SHA-256 checksum found for %s.\n' "$FFMPEG_ARCHIVE_NAME" >&2
  exit 1
fi

if [[ ! -f "$FFMPEG_ARCHIVE" ]] ||
  [[ "$(sha256sum "$FFMPEG_ARCHIVE" | awk '{ print $1 }')" != "$EXPECTED_FFMPEG_HASH" ]]; then
  curl -fL --retry 2 --silent --show-error \
    "$FFMPEG_DOWNLOAD_BASE/$FFMPEG_ARCHIVE_NAME" \
    -o "$FFMPEG_ARCHIVE"
fi
ACTUAL_FFMPEG_HASH="$(sha256sum "$FFMPEG_ARCHIVE" | awk '{ print $1 }')"
if [[ "$ACTUAL_FFMPEG_HASH" != "$EXPECTED_FFMPEG_HASH" ]]; then
  printf 'FFmpeg archive checksum mismatch: expected %s, received %s.\n' \
    "$EXPECTED_FFMPEG_HASH" "$ACTUAL_FFMPEG_HASH" >&2
  exit 1
fi

rm -rf -- "$FFMPEG_EXTRACT_DIR"
mkdir -p "$FFMPEG_EXTRACT_DIR"
tar -xf "$FFMPEG_ARCHIVE" -C "$FFMPEG_EXTRACT_DIR"
FFMPEG_ROOT="$(find "$FFMPEG_EXTRACT_DIR" -type f -path '*/bin/ffmpeg' -print -quit)"
if [[ -z "$FFMPEG_ROOT" ]]; then
  printf 'FFmpeg archive did not contain bin/ffmpeg.\n' >&2
  exit 1
fi
FFMPEG_ROOT="${FFMPEG_ROOT%/bin/ffmpeg}"
if [[ ! -x "$FFMPEG_ROOT/bin/ffprobe" || ! -d "$FFMPEG_ROOT/lib" ||
  ! -f "$FFMPEG_ROOT/LICENSE.txt" ]]; then
  printf 'FFmpeg archive is missing ffprobe, shared libraries, or its license.\n' >&2
  exit 1
fi

rm -rf -- "$FLATPAK_FILES"
mkdir -p "$FLATPAK_FILES/bin" \
  "$FLATPAK_FILES/libexec/aioconvert" \
  "$FLATPAK_FILES/share/applications" \
  "$FLATPAK_FILES/share/icons/hicolor/512x512/apps" \
  "$FLATPAK_FILES/share/licenses/com.aioconvert.aioconvert"
cp -a "$ROOT_DIR/build/linux/x64/release/bundle/." \
  "$FLATPAK_FILES/libexec/aioconvert/"
rm -f "$FLATPAK_FILES/libexec/aioconvert/lib"/libav*.so* \
  "$FLATPAK_FILES/libexec/aioconvert/lib"/libsw*.so* \
  "$FLATPAK_FILES/libexec/aioconvert/lib"/libffmpegkit.so*
install -m 755 "$FFMPEG_ROOT/bin/ffmpeg" "$FLATPAK_FILES/bin/ffmpeg"
install -m 755 "$FFMPEG_ROOT/bin/ffprobe" "$FLATPAK_FILES/bin/ffprobe"
cp -a "$FFMPEG_ROOT/lib/." "$FLATPAK_FILES/lib/"
install -m 644 "$FFMPEG_ROOT/LICENSE.txt" \
  "$FLATPAK_FILES/share/licenses/com.aioconvert.aioconvert/FFmpeg-LICENSE.txt"
FFMPEG_VERSION="$("$FFMPEG_ROOT/bin/ffmpeg" -version | sed -n '1s/^ffmpeg version //p')"
cat > "$FLATPAK_FILES/share/licenses/com.aioconvert.aioconvert/FFmpeg-NOTICE.txt" <<NOTICE
AIOconvert includes FFmpeg $FFMPEG_VERSION from BtbN/FFmpeg-Builds.
This is a GPL-licensed FFmpeg build. Build information and source:
https://github.com/BtbN/FFmpeg-Builds
https://ffmpeg.org/legal.html
NOTICE
cat > "$FLATPAK_FILES/bin/AIOconvert" <<'APP_RUN'
#!/bin/sh
APP_DIR=/app/libexec/aioconvert
export PATH="/app/bin:$PATH"
export LD_LIBRARY_PATH="/app/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
cd "$APP_DIR"
exec "$APP_DIR/AIOconvert" "$@"
APP_RUN
chmod 755 "$FLATPAK_FILES/bin/AIOconvert"
sed 's/^Exec=AppRun$/Exec=AIOconvert/' \
  "$ROOT_DIR/packaging/linux/com.aioconvert.aioconvert.desktop" \
  > "$FLATPAK_FILES/share/applications/com.aioconvert.aioconvert.desktop"
install -m 644 "$ROOT_DIR/assets/icons/aioconvert.png" \
  "$FLATPAK_FILES/share/icons/hicolor/512x512/apps/com.aioconvert.aioconvert.png"
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
  "$APP_BRANCH" \
  --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo

printf 'Created %s\n' "$OUTPUT_FILE"
