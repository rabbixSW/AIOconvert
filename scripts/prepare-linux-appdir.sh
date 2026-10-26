#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPDIR="$ROOT_DIR/build/release/AppDir"
case "$(uname -m)" in
  x86_64) FLUTTER_ARCH=x64 ;;
  aarch64|arm64) FLUTTER_ARCH=arm64 ;;
  armv7l) FLUTTER_ARCH=arm ;;
  *)
    printf 'Unsupported Linux architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac
BUNDLE_DIR="$ROOT_DIR/build/linux/$FLUTTER_ARCH/release/bundle"
LINUXDEPLOY="${LINUXDEPLOY:-linuxdeploy}"
export NO_STRIP=1

if [[ ! -x "$BUNDLE_DIR/AIOconvert" ]]; then
  printf 'Missing Linux release bundle. Run "flutter build linux --release" first.\n' >&2
  exit 1
fi

for tool in ffmpeg ffprobe; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Required host tool "%s" was not found on PATH.\n' "$tool" >&2
    exit 1
  fi
done

if ! command -v "$LINUXDEPLOY" >/dev/null 2>&1 && [[ ! -x "$LINUXDEPLOY" ]]; then
  printf 'linuxdeploy was not found. Install it or set LINUXDEPLOY to its path.\n' >&2
  exit 1
fi

rm -rf -- "$APPDIR"
mkdir -p "$APPDIR/usr/bin" \
  "$APPDIR/usr/share/applications" \
  "$APPDIR/usr/share/icons/hicolor/512x512/apps"

install -m 755 "$BUNDLE_DIR/AIOconvert" "$APPDIR/usr/bin/AIOconvert"
cp -a "$BUNDLE_DIR/data" "$APPDIR/usr/bin/data"
cp -a "$BUNDLE_DIR/lib" "$APPDIR/usr/bin/lib"

install -m 755 "$(readlink -f "$(command -v ffmpeg)")" "$APPDIR/usr/bin/ffmpeg"
install -m 755 "$(readlink -f "$(command -v ffprobe)")" "$APPDIR/usr/bin/ffprobe"
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
  --executable "$APPDIR/usr/bin/ffmpeg" \
  --executable "$APPDIR/usr/bin/ffprobe" \
  --desktop-file "$APPDIR/usr/share/applications/com.aioconvert.aioconvert.desktop" \
  --icon-file "$APPDIR/usr/share/icons/hicolor/512x512/apps/com.aioconvert.aioconvert.png"
