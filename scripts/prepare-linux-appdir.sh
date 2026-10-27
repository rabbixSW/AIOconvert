#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPDIR="$ROOT_DIR/build/release/AppDir"
FFMPEG_DIR="$ROOT_DIR/build/release/appimage-ffmpeg"
FFMPEG_CHECKSUMS="$FFMPEG_DIR/checksums.sha256"
FFMPEG_EXTRACT_DIR="$FFMPEG_DIR/extracted"
FFMPEG_DOWNLOAD_BASE="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest"
case "$(uname -m)" in
  x86_64)
    FLUTTER_ARCH=x64
    FFMPEG_ARCHIVE_NAME="ffmpeg-master-latest-linux64-gpl-shared.tar.xz"
    ;;
  aarch64|arm64)
    FLUTTER_ARCH=arm64
    FFMPEG_ARCHIVE_NAME="ffmpeg-master-latest-linuxarm64-gpl-shared.tar.xz"
    ;;
  armv7l)
    printf 'The AppImage FFmpeg bundle is unavailable for armv7l.\n' >&2
    exit 1
    ;;
  *)
    printf 'Unsupported Linux architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac
FFMPEG_ARCHIVE="$FFMPEG_DIR/$FFMPEG_ARCHIVE_NAME"
BUNDLE_DIR="$ROOT_DIR/build/linux/$FLUTTER_ARCH/release/bundle"
LINUXDEPLOY="${LINUXDEPLOY:-linuxdeploy}"
export NO_STRIP=1

if [[ ! -x "$BUNDLE_DIR/AIOconvert" ]]; then
  printf 'Missing Linux release bundle. Run "flutter build linux --release" first.\n' >&2
  exit 1
fi

for tool in curl sha256sum tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Required host tool "%s" was not found on PATH.\n' "$tool" >&2
    exit 1
  fi
done

if ! command -v "$LINUXDEPLOY" >/dev/null 2>&1 && [[ ! -x "$LINUXDEPLOY" ]]; then
  printf 'linuxdeploy was not found. Install it or set LINUXDEPLOY to its path.\n' >&2
  exit 1
fi

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
FFMPEG_ROOT="$(find "$FFMPEG_EXTRACT_DIR" -type f -path '*/bin/ffprobe' -print -quit)"
if [[ -z "$FFMPEG_ROOT" ]]; then
  printf 'FFmpeg archive did not contain bin/ffprobe.\n' >&2
  exit 1
fi
FFMPEG_ROOT="${FFMPEG_ROOT%/bin/ffprobe}"
if [[ ! -x "$FFMPEG_ROOT/bin/ffmpeg" || ! -d "$FFMPEG_ROOT/lib" ||
  ! -f "$FFMPEG_ROOT/LICENSE.txt" ]]; then
  printf 'FFmpeg archive is missing ffmpeg, shared libraries, or its license.\n' >&2
  exit 1
fi

rm -rf -- "$APPDIR"
mkdir -p "$APPDIR/usr/bin" \
  "$APPDIR/usr/lib" \
  "$APPDIR/usr/share/applications" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps" \
  "$APPDIR/usr/share/licenses/com.aioconvert.aioconvert"

install -m 755 "$BUNDLE_DIR/AIOconvert" "$APPDIR/usr/bin/AIOconvert"
cp -a "$BUNDLE_DIR/data" "$APPDIR/usr/bin/data"
cp -a "$BUNDLE_DIR/lib" "$APPDIR/usr/bin/lib"

install -m 755 "$FFMPEG_ROOT/bin/ffmpeg" "$APPDIR/usr/bin/ffmpeg"
install -m 755 "$FFMPEG_ROOT/bin/ffprobe" "$APPDIR/usr/bin/ffprobe"
cp -a "$FFMPEG_ROOT/lib/." "$APPDIR/usr/lib/"
install -m 644 "$FFMPEG_ROOT/LICENSE.txt" \
  "$APPDIR/usr/share/licenses/com.aioconvert.aioconvert/FFmpeg-LICENSE.txt"
FFMPEG_VERSION="$("$FFMPEG_ROOT/bin/ffmpeg" -version | sed -n '1s/^ffmpeg version //p')"
cat > "$APPDIR/usr/share/licenses/com.aioconvert.aioconvert/FFmpeg-NOTICE.txt" <<NOTICE
AIOconvert includes FFmpeg $FFMPEG_VERSION from BtbN/FFmpeg-Builds.
This is a GPL-licensed FFmpeg build. Build information and source:
https://github.com/BtbN/FFmpeg-Builds
https://ffmpeg.org/legal.html
NOTICE
install -m 644 "$ROOT_DIR/packaging/linux/com.aioconvert.aioconvert.desktop" \
  "$APPDIR/usr/share/applications/com.aioconvert.aioconvert.desktop"
install -m 644 "$ROOT_DIR/assets/icons/aioconvert.png" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps/com.aioconvert.aioconvert.png"

cat > "$APPDIR/AppRun" <<'APP_RUN'
#!/bin/sh
HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
export PATH="$HERE/usr/bin:$PATH"
export LD_LIBRARY_PATH="$HERE/usr/lib:$HERE/usr/bin/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
cd "$HERE/usr/bin"
exec "$HERE/usr/bin/AIOconvert" "$@"
APP_RUN
chmod 755 "$APPDIR/AppRun"

"$LINUXDEPLOY" \
  --appdir "$APPDIR" \
  --executable "$APPDIR/usr/bin/AIOconvert" \
  --desktop-file "$APPDIR/usr/share/applications/com.aioconvert.aioconvert.desktop" \
  --icon-file "$APPDIR/usr/share/icons/hicolor/512x512/apps/com.aioconvert.aioconvert.png"
